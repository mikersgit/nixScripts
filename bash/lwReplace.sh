#!/bin/bash

# from the current directory replace likewise rpm on listed servers with
# the most recent likewise rpm in the cwd.

#
# initialize variables, make sure needed args supplied
#
function init() {
	if (( ${#} < 1 ))
	then
		echo "Need ip addresses of cluster nodes to update"
		exit 2
	fi

	rpmHost='e6s14'
	e6s14Key='ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA0m0AEhXLWHI4SIAbp4Pd6wDAuAsFW7P+HmjAhNzl1zAILEwyjsKwLNGo24QMhS89e2zSK8dDYG5Sgau6sRwMaa1BGYgi8R0HYlXEE/vMgkHL+X+C+4K2d7YzEhXjTRQA0jXpAn6oOpKAECMv0dSYfG2FbxkLO4WAOKVRaPoXcAB2VmNX8eWSRY74Th42K18uSO+ekOymfjcQ6JzUxy3i/Tl+LDZWzXtQvjkL4cWLgLhd5nGvB94Syf5pifYbkBIjPpU4uQCmuYFPkZo0MObFadWsVTwsrE7GNFkTd0lmENGAYjn1jCa31lpBCeqSFRa0RTwEFG3zyNEhcNCkEHLWvw== mwroberts@e6s14'
} # end init()

#
# put ssh key inplace it destination IP doesn't have it already
#
function testKey() {
	for i in ${ips[*]}
	{
		ssh -q root@${i} <<- eof
		if grep mwroberts ~/.ssh/authorized_keys >/dev/null 2>&1
		then
			echo "has key"
		else
			echo "needs key"
			echo "${e6s14Key}" >> ~/.ssh/authorized_keys
		fi
		eof
	}
} #end testKey()

#
# check that the cwd has a likewise rpm, then set the most recent
# rpm to be the one to install. Query the user before continuing
# to make sure this is the correct rpm, assume 'yes' after 15 seconds
function rpmCheck() {
	fnd=$(ls *likewise*rpm 2>/dev/null | wc -l)
	if ((fnd<1))
	then
		echo "No likewise rpm found in $PWD"
		exit 2
	fi
	rpm=$(ls -lrS | tail -1|awk '{print $NF}')

	ans="y"
	echo "Install ${rpm} on ${ips[*]} ([y]/n)?"
	read -t 15 ans
	[[ ${ans} = [nN] ]] && exit 1
} # end rpmCheck()

#
# connect to supplied IP addresses via ssh
# 1. remove previous likewise rpm
# 2. install the most recent rpm in cwd
# 3. join dev.net domain
# 4. query domain values
# 5. restart lw* services
function rpmReplace() {
set -x
	domain='dev.net';duser='Administrator';dpassw='hpinvent#1'
	dom='domainjoin-cli'
	domj="${dom} join ${domain} ${duser} ${dpassw}"
	domq="${dom} query"
	rpath='/var/rpm'; rpm="${rpath}/${rpm}"
	rpmE='rpm -ev' ; rpmI='rpm -hiv'
	s3='sleep 3' ; s10='sleep 10'
	for i in ${ips[*]}
	{
		ssh root@${i} "mkdir -p ${rpath}"
		ssh root@${i} "mount ${rpmHost}:${PWD} ${rpath}"
		rmRpm=$(ssh root@${i} "rpm -qa \*likewise\*")
		ssh root@${i} "${rpmE} ${rmRpm}; ${s3}; ${rpmI} ${rpm}; ${s10}; ${domj}; ${domq}; bash ~/bin/restartlw"
	}
} # end rpmReplace()

init ${@}
declare -a ips=(${@})
rpmCheck
testKey
rpmReplace
ssh root@${i} "umount ${rpath}"
