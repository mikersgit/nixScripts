#!/bin/bash
# script to gather values to be used to setup cluster nodes

# @author: Michael Roberts
# @date: 9-Feb-2014
#

echo -e "\n\t***************\n\t*EXPERIMENTAL!*\n\t***************\n"
echo "Exit now if this is NOT what you expected."
sleep 5

set -x
# Global values
#
prefix=20
curlAuth='-k -u ibrix:ibrix'
rackIP12="10.33" # first two octets of cluster IPs

read -p "Blade number: " bn
read -p "Cluster number: " cn
read -p "Number of nodes in the cluster: " clusterSz
read -p "IP of gateway: " gtway

if (( ${#bn} == 0 || ${#cn} == 0 || ${#clusterSz} == 0 ))
then
	echo "ERROR: Missing values."
	exit 2
fi

function cleanKnownHosts () {
	tmpfl=$(mktemp)
	knHosts='.ssh/known_hosts'
	\cp ${knHosts} ${knHosts}"_$(date '+%Y:%m:%d:%H:%M:%S')"
	for n in ${loIP[*]} ${UnoIP[*]}
	{
		sed "/${n}/d" ${knHosts} > ${tmpfl}
		[[ -s ${tmpfl} ]] && \mv ${tmpfl} ${knHosts}
	}
	chmod 644 ${knHosts}
}

function pushSSH () {
	key=$(cat .ssh/id_dsa.pub)
	echo ${key}
	a=".ssh/authorized_keys"
	for n in ${loIP[*]}
	{
		echo ${key} | ssh -q ${n} "cat - >> ${a}"
	}
}

fresh=0
read -p "Use existing cluster? ([y]/n): " ans
if [[ ${ans} = [nN] ]]
then
	echo "Preparing to destroy existing cluster ${cn}"
	sleep 5
	fresh=1
	Unity/CleanupCluster.sh ${cn}
	Unity/UnityCluster.sh ${cn} ${clusterSz}
fi

((bnm1=bn-1)) # third octet is blade number minus one
rackIP123=${rackIP12}"."${bnm1} # add on third octet

for ((i=0;i<${clusterSz};i++))
{
	((j=i+1))
	((k=i+5)) # skip to the fifth address in case they build 4 node cluster
	read -p "last two octets for 127.127.* IP for node ${i} (eg. [1.1${j}]): " loIP[${i}] 
	(( ${#loIP[${i}]} < 1 )) && loIP[${i}]="1.1${j}"
	oct3=${loIP[${i}]%.*}
	loIP[${i}]="127.127."${loIP[${i}]}
	read -p "User IP address for node ${i} (eg. [${rackIP123}.2${j}]): " UnoIP[${i}]
	(( ${#UnoIP[${i}]} < 1 )) && UnoIP[${i}]="${rackIP123}.2${j}"
	read -p "AD name for node ${i} (eg. [KVM0${bnm1}-00${j}]): " ADnnIP[${i}]
	(( ${#ADnnIP[${i}]} < 1 )) && ADnnIP[${i}]="KVM0${bnm1}-00${j}"
	read -p "IP address for mtree${i} VIF (eg. [${rackIP123}.2${k}]): " mtIP[${i}]
	(( ${#mtIP[${i}]} < 1 )) && mtIP[${i}]="${rackIP123}.2${k}"
}

# if a fresh cluster image was used then cleanup known hosts and setup
# ssh connection
#
if (( fresh ))
then
	cleanKnownHosts
	pushSSH
fi

echo ${loIP[*]}
echo ${oct3}
echo ${UnoIP[*]}
echo ${ADnnIP[*]}
echo ${mtIP[*]}
echo ${gtway}

clusterID=$(curl --header 'Accept: application/xml' "https://${loIP[0]}:9443/pml/clustermanagement?pretty=true" ${curlAuth} 2>/dev/null |
	awk '$1 ~ /uuid/ {
		gsub("uuid","",$0)
		sub("<>","",$0)
		sub("</>","",$0)
		print}'
	)

echo ${clusterID}

j=0
for n in ${loIP[*]}
{
	nodeHst[${j}]=$(ssh ${n} "hostname")
	((j+=1))
}

for n in ${loIP[*]}
{
	#ssh ${n} "hpsp_network -emulator -request use_ns_config"
	ssh ${n} "/sbin/ip addr sh dev eth0"
}

for n in ${loIP[*]}
{
	ssh ${n} "service infrastructure_manager restart"
	sleep 5
}

for n in ${loIP[*]}
{
	ssh ${n} "pm_server_config -l ;pm_server_config -i"
}

for n in ${loIP[*]}
{
	ssh ${n} "hpsp_network -cluster -request list"
}

for ((j=0;j<${clusterSz};j++))
{
	for n in ${loIP[*]}
	{
		curl --header 'Accept: application/xml' ${curlAuth} "https://${n}:9443/network-services/ns/nmod/node/state?pretty=true"
	}
}

for n in ${loIP[*]}
{
	ssh ${n} "pm_server_config -l ;pm_server_config -i"
	ssh ${n} "hpspns_nod_examine -p /config/network-services/nmod -a | grep hostname"
}

endPtopts="-endpoint -request add_user_address -node "
gtwyPtopts="-gateway -request update_gateway_address -node "
for ((n=0;n<${clusterSz};n++))
{
	ssh ${loIP[${n}]} "hpsp_network ${endPtopts} ${nodeHst[${n}]} -address ${UnoIP[${n}]} -prefix ${prefix}"
	ssh ${loIP[${n}]} "hpsp_network ${gtwyPtopts} ${nodeHst[${n}]} -address ${gtway} -prefix 0"
}

for n in ${loIP[*]}
{
	ssh ${n} "hpsp_network -dns -request update_dns_config -addresses '10.35.0.1 10.10.0.6 10.10.15.8' -suffixes 'ibftc.vpi.hp.com 2008ad.lab enas.net fc.hp.com hp.com'"
}

# Verify servers in the cluster
curl --header 'Accept: text/plain' "https://127.127.${oct3}.10:9443/hwmonitor/servers?media=txt" ${curlAuth}

# Verify storage cluster details
curl --header 'Accept: application/xml' "https://127.127.${oct3}.10:9443/hwmonitor/storages?listServers=false&media=txt&pretty=true" ${curlAuth}

# Verify Vendor Storage
curl --header 'Accept: text/plain' "https://127.127.${oct3}.10:9443/hwmonitor/storages?listServers=false&media=txt" ${curlAuth}

# Initiate Storage Discovery
curl -i --data 'discoverstorage=true' "https://127.127.${oct3}.10:9443/services/filesystemservice/volumes?media=txt" ${curlAuth}

#Show discovered volumes
curl --header 'Accept: application/xml' "https://127.127.${oct3}.10:9443/services/filesystemservice/volumes?pretty=true&media=txt" ${curlAuth} | tee vols.xml

# Create filesystem
curl -i --header 'Content-Type: application/xml' --header 'Accept: application/xml' --data "@vols.xml" "https://127.127.${oct3}.10:9443/services/filesystemservice/filesystems?media=txt" ${curlAuth}

# List filesystem
curl --header 'Accept: application/xml' "https://127.127.${oct3}.10:9443/services/filesystemservice/filesystems?pretty=true&media=txt" ${curlAuth}

# Mount filesystem
curl -i --request PUT --data 'mounted=true' "https://127.127.${oct3}.10:9443/services/filesystemservice/filesystems/isisFS?media=txt" ${curlAuth}

# Wait for the filesystem to mount which may take over a minute as the
# filesystem is still initializing
echo "Wait one minute for file systems to mount"
sleep 60

# Use the cluster UUID to create the mTree:
curl -i --header 'Content-Type: application/xml' --header 'Accept: application/xml'  ${curlAuth} --data '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><mTree><name>mt01</name></mTree>' "https://127.127.${oct3}.10:9443/hp/rest/provisioning/${clusterID}/file/storagePool/isisFS/virtualServer?pretty=true"

# Adding IP Addresses:
curl  -i --header 'Content-Type: application/xml' --header 'Accept: application/xml' --data "<?xml version='1.0' encoding='UTF-8' standalone='yes'?><hpspns-network-address-selector><vlanTag>0</vlanTag><prefixLen>20</prefixLen><address>${mtree01VIF}</address><networkName>user</networkName></hpspns-network-address-selector>" "https://127.127.${oct3}.10:9443/hp/rest/provisioning/${clusterID}/file/storagePool/isisFS/virtualServer/mt01/networkAddressSelectors" ${curlAuth}

# List mtree:
curl -i --header 'Accept: application/xml' "https://127.127.${oct3}.10:9443/hp/rest/provisioning/${clusterID}/file/storagePool/isisFS/virtualServer/mt01/networkAddressSelectors?pretty=True" ${curlAuth}

# Creating an STREE
curl -i --header 'Accept: application/xml' ${curlAuth} --header 'Content-Type: application/xml' -d "<?xml version='1.0' encoding='UTF-8' standalone='yes'?><sTree><name>st01</name><segment>1</segment></sTree>" "https://127.127.${oct3}.10:9443/hp/rest/provisioning/${clusterID}/file/storagePool/isisFS/virtualServer/mt01/fileStore/?pretty=true"


# Notes from jim m.
#node1IP=10.33.(blade# -1).firstIPinRange 
#node2IP=10.33.(blade# -1).secondIPIPinRange
#mtree01VIF=10.33.(blade# -1).firstIPinRange+4
#mtree02VIF=10.33.(blade# -1).firstIPinRange+5
#gateway=10.33.15.254
#prefix=20
#node1ADName=(blade# -1)-00(firstIPinRange) 
#node2ADName=(blade# -1)-00(secondIPIPinRange)

