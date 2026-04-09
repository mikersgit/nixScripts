#!/bin/bash

LogContextLines=40
LOGS=(dmesg /var/log/modem.log /home/exodus/Engine/GenesisMcp.log)

function usage() {
	echo "${0##*/} -g <sec> -f <sec>"
	echo "	-g Seconds to wait between checks while gateway is in good state"
	echo "	-f Seconds to wait between checks while gateway is down waiting to recover"
	echo " eg. ${0##*/} -g 20 -f 5" 
	echo "Monitors the status of cellmodem as default gateway."
	echo "All output is to STDOUT, redirect or pipe to file to keep record"
	echo "If the status is good, waits -g <sec> to check again."
	echo "If the status is fail, waits -f <sec> to check again."
	echo "The max retries on failure is 20 times, then quit checking"
	exit
}

function grabLogs() {
	local LogLines=$1
	echo "====== dmesg ========="
	${LOGS[0]} | tail -${LogLines}
	echo "====== modem.log ========="
	tail -${LogLines} ${LOGS[1]}
	echo "====== GenesisMcp.log ========="
	tail -${LogLines} ${LOGS[2]}
}

if [[ $# -lt 4 ]];then
	usage
fi

while getopts "g:f:" arg;
do
case ${arg} in
  	g)
		goodWait=${OPTARG}
        ;;
  	f)
		failWait=${OPTARG}
        ;;
  	*) usage ;;
	esac
done

echo "====== Start ====="
date
ip r
echo "======== Initial info in logs ========"
# less than fail context 
grabLogs 20
echo "======== End Initial log snippets ========"
cnt=0
lcnt=0
while :
do
	rte=$(ip r |grep ^default|grep rmnet)
 	if [[ ${#rte} -gt 0 ]];then
		((cnt+=1))
		if [[ ${cnt} -ge 10 ]];then
			echo "running "$(date)
			cnt=0
		fi
 		sleep ${goodWait}
 	else
		((lcnt+=1))
 		echo "lost route" $(date)
		if [[ ${lcnt} -ge 20 ]];then
			echo "####### Quitting monitor #######"
			exit 1
		fi
		grabLogs ${LogContextLines}
		ip r
		sleep ${failWait}
 	fi
done
echo "====== End ====="
