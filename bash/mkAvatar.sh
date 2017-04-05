#!/bin/bash

# script to get Astra bits, install them, create avatar domain,
# create/mount file system
#####

### subdirectories on rpm repository to query
##
declare -a rpmDirs=(/FileSystem/Avatar-ISIS/advfs_debug_16K/ \
	    /FileSystem/Avatar-ISIS/isis_debug_16K/ \
	    /HPProtocols/ \
	    /PML/ \
	    /Platform/ \
	    /hpsp_qr_rpms/)

### Initialize variables
##
function init() {
    : ${RELEASE:='IR2'} # if not set, make it IR2
    RTOOL='/usr/local/isis/bin/rtool'
    baseURL='http://seahawk.usa.hp.com/vpishare/Unity'
    relURL=${baseURL}/${RELEASE}
    BITDIR='/tmp/bits'
}

### Generate list of RPMS from the curl listing.
## this is meant to be called in a pipeline of commands.
##
function getRpmList() {
	grep "rpm"|
	awk -F "<a" '{gsub("\""," ")
		split($2,a," ")
		if (length(a[2]>4) && a[2] ~ /rpm$/)
		print a[2]}'
}

### Given the RPM repo and subdirectories to traverse, pull the
## RPMS via curl
## calls function 'getRpmList'
##
function getBits() {
	echo -e "\n********\nGet RPMS\n********\n"
	[[ ! -d ${BITDIR} ]] && mkdir ${BITDIR}
	cd ${BITDIR}
	for d in ${rpmDirs[*]}
	{
		echo -e "========\n${d}\n==========="
		for r in $(curl ${relURL}/${d} 2>/dev/null | getRpmList)
		{ 
			echo -e "\t========\n\t${r}\n\t==========="
			curl -o ${r} ${relURL}/${d}/${r} 2>/dev/null
		}
	}
}

### Install (no force) the rpms that were pulled
##
function installBits() {
	echo -e "\n********\nInstall RPMS\n********\n"
	for p in advfs isis hpsp \
                [Pp]rotocol hpprotocol infrastruc kernel-module
	{
		rpm -hiv ${BITDIR}/${p}*.rpm
	}
}

### List the avatar install directory contents, and some of the
## rpm -qi info from the RPMs
##
function listBits() {
	echo -e "\n********\nList installed RPMS\n********\n"
	ls /opt/hp/avatarfs/
	ls /opt/hp/avatarfs/sbin/
	for r in $(ls ${BITDIR}/*rpm)
	{
		r=$(echo ${r##${BITDIR}/})
		echo -e "=============\n${r}\n==============="
		rpm -qi ${r%.rpm} 2>&1 |
                grep -e ^Name -e ^Version -e ^Release
	}
}

### Make sure the kernel modules are loaded
##
function activateBits() {
	echo -e "\n********\nLoad modules\n********\n"
	modprobe advfs
	modprobe isis
	lsmod |grep -i -e adv -e isis
}

### Give a list of block devices to select to create disk domain
## then create a domain, and file system. Then mount and list the
## file system.
##
function createDomain() {
	echo -e "\n********\nCreate and Mount avatar FS\n********\n"
	echo "Available block devices"
	printf "%-39s %s\n" "ID" "Block dev"
	printf "======================================= =========\n"
 	ls -l /dev/disk/by-id/ |
		awk '{if(NF>5 && $9 ~ /scsi/) {
			sub("../../","",$NF)
			printf("%s /dev/%s\n",$9,$NF)
			}
		}'

        # we used to be able to grab disks from proc/partitions
 	#cat /proc/partitions |
		#grep -v sda  |
		#awk '{if($1 ~ /major/ || $1 ~ /^$/) next
                #   printf("%s %d GB\n",$NF,($3/10^6))}'
	read -p"device (the scsi... string): " DEV
	read -p"domain name: " DomainName
	read -p"file system name: " FSName
	domain create -o ipfs3 $DomainName -f /dev/disk/by-id/${DEV}
	mkfs -t advfs -o ipfs3 \
             -f $DomainName/${FSName} ${FSName} ${FSName} 1 1 1
	${RTOOL} localhost
	${RTOOL} addseg /dev/advfs/${DomainName}/${FSName} \
                ${FSName} ${FSName} 1 1 localhost
	mkdir /${FSName}
	mount -t isis ${FSName} /${FSName}/ -o fsname=${FSName}
}

### List disk domains, and any isis file systems
##
function listDomain() {
	echo -e "\t============\n\tDomains\n\t============"
	domain list
	echo -e "\t============\n\tMounted ISIS FS\n\t============"
	df -lt isis
}

function usage() {
    echo "${1} [-R] [-L|I] [-F] [-?h]"
    echo "-R IRnumber provide the IR release string eg. 'IR2'"
    echo "-L  get the advfs bits and list them"
    echo "-I  get the advfs bits and install them"
    echo "-F  Create disk domain, create and mount file system"
    echo "If no options are given '-I -F' are implied"
    exit 2
}

here=${PWD}
LISTBITS=0
INSTALL=0
FILESYSTEM=0

### Command line parsing
##
while getopts :R:LIF OPT; do
    case $OPT in
        R) RELEASE=${OPTARG}
	;;L)
	    LISTBITS=1
	;;I)
	    INSTALL=1
	;;F)
	    FILESYSTEM=1
	;;*)
	usage ${0##*/}
    esac
done
shift $[ OPTIND - 1 ]

# now that command line is parsed, init variables
init

if ((!INSTALL && !FILESYSTEM && !LISTBITS))
then
    INSTALL=1 ; FILESYSTEM=1
fi

if ((LISTBITS))
then
    getBits
    listBits
    (( !FILESYSTEM )) && listDomain
fi

if ((INSTALL && !LISTBITS))
then
    getBits
    installBits
    listBits
    activateBits
fi

if ((FILESYSTEM))
then
    createDomain
    listDomain
fi
