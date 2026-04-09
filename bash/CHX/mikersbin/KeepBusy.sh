#!/bin/bash
# keep network and screen busy so connection does not go to sleep
# ping PINGCNT times every SLEEPSECONDS seconds
# arping PINGCNT times every SLEEPSECONDS seconds #arping requires sudo
PINGCNT=4
SLEEPSECONDS=1800
#SLEEPSECONDS=10
STOPFILE=$HOME/StopBusy
RESTART=$HOME/RestartBusy
DNSSERV="8.8.8.8"
CELLMODEM="63.47.115.96"
HOMESUBNET="192.168.0"

function setupPingArrays() {
	# get IP address of laptop where RDP is being run
	LAPTOPIP=$(netstat -t -6|grep ESTAB|grep "${HOMESUBNET}"|awk '{split($5,a,":");print a[1]}')
	#LAPTOPIP=192.168.0.47
	PINGTARGET=(${DNSSERV} ${CELLMODEM} ${LAPTOPIP})
	# use 'arping' for windows laptop because ICMP echo is off by default in windows, arp can't be easily blocked
	PINGMETHOD=(ping ping arping)
}

setupPingArrays

while :
do
	if [ -e $STOPFILE ]
	then
		echo "Stopping via $STOPFILE"
		rm $STOPFILE
		exit 1
	fi
	if [ -e $RESTART ]
	then
		echo "Refresh LAPTOPIP via $RESTART"
		rm $RESTART
		setupPingArrays
	fi
	cnt=$(( ${#PINGTARGET[*]}-1 ))
	for p in $(seq 0 $cnt)
	{
		${PINGMETHOD[$p]} -c $PINGCNT ${PINGTARGET[$p]}
		ret=$?
		if [[ $ret -eq 1 && $p -eq $cnt ]] ; then
			setupPingArrays
		fi
	}
	echo -e "\t** current time: $(date)\n\t** next ping at: $(date -d "now +${SLEEPSECONDS}seconds")"
	echo "Use $STOPFILE and $RESTART to control program"
	sleep $SLEEPSECONDS
done
