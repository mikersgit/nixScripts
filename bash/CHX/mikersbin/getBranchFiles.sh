#!/bin/bash
ver=$(date '+%b%d%H%M')
FromBranch=$1
if [ ${#} -lt 1 ] ; then
	echo "Need branch name from which to pull files"
	exit 1
fi
# an "infile" might look like
###
#current/etc/pcsf/boot_tasks
#current/usr/local/bin/ip_check.sh
#current/usr/local/bin/networkctrl
#current/usr/local/bin/virtual-nic.sh
#current/usr/local/sbin/checkGateway.sh
#current/usr/local/sbin/checkNetworkConfFiles.src
#current/usr/local/sbin/check_services.sh
#current/usr/local/sbin/ifdown
#current/var/spool/cron/crontabs/root
[ -e sdiffFile.txt ] && rm sdiffFile.txt
if [ ! -e infile ] ; then
       	echo "No input file 'infile'"
	exit 1
fi
for i in $(< infile)
do
	OUTFILE=${i##*/}${ver}
	if [ -e ${OUTFILE} ] ; then
		OUTFILE=${OUTFILE}${RANDOM}
	fi
	git show ${FromBranch}:${i} >${OUTFILE}
	if [ ! -s ${OUTFILE} ] ;then
		echo "rm ${i}" >> sdiffFile.txt
	else
		echo "sdiff -s ${OUTFILE} ${i}" >> sdiffFile.txt
	fi
done
