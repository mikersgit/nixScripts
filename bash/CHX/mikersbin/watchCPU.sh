#!/bin/bash
# ChampionX 2026
# Capture corefile, process, and system information if specified process exceeds the CPU threshold

if [[ ${#} < 1 ]];then
	echo 'Provide cpu percentage threshold >0 and <100'
	echo "${0##*/} 20"
	exit 1
fi

PIDFILE="/run/exodus/exoduscmain.pid"
PROCESS="ExodusC"

function gatherInfo() {
	prefix=$(date '+%d%H%M%S')
	PID=$(< ${PIDFILE})
	netstat -ptunwv >${prefix}.excore.netstat
	vmstat -n 1 4 >${prefix}.excore.vmstat
	free -h > ${prefix}.excore.memory
	pmap -px $PID > ${prefix}.excore.pmap
	ls -l /proc/${PID}/fd > ${prefix}.excore.fd
	strace -o ${prefix}.excore.strace -f -p ${PID} 1>/dev/null  2>/dev/null &
	sleep 2
	kill %1
	gcore -o ${prefix}.excore.core ${PID} 1>/dev/null  2>/dev/null
	xz -q -T0 ${prefix}.excore.core.${PID}
}

while :
do
	RES=$(top -n1 -b -p $(< ${PIDFILE})|
		awk -v proc="${PROCESS}" -v cpu=${1} '{if ($12 ~ proc"*" && $9 > cpu) print $9}')
	if [[ ${#RES} > 0 ]];then
		echo "CPU: ${RES}"
		gatherInfo
		exit
	fi
	sleep 5
done
