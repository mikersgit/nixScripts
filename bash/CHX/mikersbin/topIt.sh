#!/bin/bash
#
# in /etc/pcsf/boot_tasks add these lines at the end before 'exit 0'
# this can help determine the process going on between early boot and hmi start
#        if [ -e /home/exodus/TRACE ] ; then
#               echo "TRACING processes to /var/log/topOut.txt"
#               nohup /home/exodus/topIt.sh &
#       fi

WAIT=2
TLINES=15
OPTS=""
OUT=/var/log/topOut.txt
STOPFILE=/home/exodus/STOPTRACE
rm -f ${OUT}
function GetVersions() {
	ehm=/home/exodus
	strings ${ehm}/lib/libRIB2.so.1.0 |grep V5 >> ${OUT}
	echo -n "Genesis DLL build date: " >> ${OUT}
	strings ${ehm}/Engine/GenesisMcp.dll |grep "\/2023" >> ${OUT}
}
GetVersions
TR=/home/exodus/TRACE
[ -e ${TR} ] && . ${TR}
chmod a+rw ${OUT}
chown exodus:users ${OUT}
export COLUMNS=120
while :
do
	top -cb -n 1 ${OPTS} |head -n ${TLINES} >> ${OUT}
	# vmstat -p /dev/mmcblk1p1 1 2 >> ${OUT} # duplicates info from -nd
	vmstat -nd 1 2 |grep -i -e total -e ^disk -e mmcblk1[[:space:]] >> ${OUT}
	vmstat -s |grep -v -e swap >> ${OUT}
	sleep ${WAIT}
	if [ -e /home/exodus/STOPTRACE ] ; then
		echo "Found  ${STOPFILE}, exiting" >> ${OUT}
		rm -f ${STOPFILE}
		exit 
	fi
done
