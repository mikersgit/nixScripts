#!/bin/bash
#
# reboot system maxcnt times, collecting network info before each reboot
# call script from boot_tasks inserted just before last 'exit 0' statement
#

init() {
	MAXFILE=/etc/pcsf/maxcnt
	CNTFILE=/etc/pcsf/cntFile
	LOGFILE=/etc/pcsf/testLog.log
	export TZ='US/Mountain'
}

usage() {
	echo "${0##*/} -[m <int>] [R|h]"
	echo "  m <integer> set maximum number of reboots, reset cycle counter"
	echo "  R remove results file ${LOGFILE}" 
	echo "  h help message"
	echo "example: set max cycles to 30 and clear test log file"
	echo "	${0##*/} -m 30 -R"
	exit 1
}

userCheck() {
	if [[ $(id -u) -ne 0 ]]
	then
		
		echo "	#### Hey $(whoami) you must be root. ####"
		usage
	fi
}

gatherReboot() {
	echo "##### $(date) cycle $cnt ########" >> ${LOGFILE}
	/sbin/ip a sh dev eth0 |grep -v valid >> ${LOGFILE}
	/sbin/ip a sh dev eth1 |grep -v valid >> ${LOGFILE}
	/sbin/shutdown -ry now
}

finalize() {
	echo "==========================================" >> ${LOGFILE}
	echo "========= Cycles SUMMARY =================" >> ${LOGFILE}
	echo "==========================================" >> ${LOGFILE}
	grep ether ${LOGFILE} > t ; cat t >> ${LOGFILE} 
	echo "==========================================" >> ${LOGFILE}
	echo "========= Unique HW addresses ============" >> ${LOGFILE}
	echo "==========================================" >> ${LOGFILE}
	sort -u t >> ${LOGFILE}
	rm -f t
	echo "==========================================" >> ${LOGFILE}
	echo "========= Conf Files =====================" >> ${LOGFILE}
	echo "==========================================" >> ${LOGFILE}
	for c in /etc/network/interfaces /etc/network/interfaces.d/eth*
	{
		echo -e "\t====== ${c} ======" >> ${LOGFILE}
		cat ${c} >> ${LOGFILE}
	}
	echo "=========== $(date) Done Testing $cnt cycles ==========" >> ${LOGFILE}
}

setCycle() {
	minutesToComplete=$(echo ${OPTARG} |awk '{printf "%d\n", ($1+($1*.17))+1}')
	echo ${OPTARG} > ${MAXFILE}
	echo 0 > ${CNTFILE}
	echo "## Max cycles: ${OPTARG}"
	echo "## Logged to: ${LOGFILE}"
	echo "Should complete around $(date -d "now +${minutesToComplete}mins")"
}

resetCycle() {
	rm -f ${LOGFILE}
	echo 0 > ${CNTFILE}
}

getCurrentCounters() {
	if [ ! -e  ${CNTFILE} ]
	then
		usage
	fi
	maxcnt=$(<${MAXFILE})
	cnt=$(< ${CNTFILE})

	if [[ $cnt -eq 0 ]]
	then
		echo "=========== $(date) Start Testing $maxcnt cycles ==========" >> ${LOGFILE}
	fi
	# increment the cycle count
	echo ${cnt}|awk '{print $1+1}' > ${CNTFILE}
}

main() {
	getCurrentCounters

	if [[ $cnt -ge $maxcnt ]]
	then
		finalize
	else
		gatherReboot
	fi
}

init
userCheck

while getopts "m:Rh" arg;
do
case ${arg} in 
	m) setCycle 
	    ;;
	R) resetCycle
	    ;;
	h|*) usage
	    ;;
esac
done

main
