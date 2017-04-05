#!/bin/bash

# Monitor various memory metrics of a system and save
# to rotated logs.
#

logFlBase='/var/log/MemMonitor_log'
logFl=${logFlBase}
OldLogDir='/var/log/OldMemLogs'

#
# If we've crossed the day boundary move all the logs to date tagged
#
function mvLogs() {
	logDirTs=$(date "+%Y_%m_%d")
	
	# get day number of newest file
	#
	logDay=$(ls -l --time-style=+%w ${logFlBase}.* 2>/dev/null|sort -k6,6 -n|
			tail -1|awk '{print $6}')
	thisDay=$(date "+%w")
	if (( thisDay != logDay ))
	then
		mkdir -p ${OldLogDir}/${logDirTs}
		local here=${PWD}
		mv ${logFlBase}* ${OldLogDir}/${logDirTs}
		cd ${OldLogDir}/${logDirTs}
		gzip -9 ${logFlBase##*/}*
		cd ${here}
	fi
}

# if files to rotate do not exist,
# create four files through which to rotate:
# file '4' will be newest file
function initLogs() {
        for d in 1 2 3 4
        {
                ts=$(date -d "yesterday + ${d} hour" '+%Y%m%d%H%M')
                touch -t ${ts} ${logFlBase}.${d}
        }
}

#
# rotate logs
# set the current log file to be the oldest in the list
function rotateLog() {
        # initialize log files if none exist
        (( $(ls ${logFlBase}* 2>/dev/null |wc -l) < 1 )) &&
                initLogs
        local flPattern="${logFlBase}.[[:digit:]]"
	
        declare a=($(ls -lrt ${flPattern} 2>/dev/null|awk '{print $NF}'))

        # make sure there was content before resetting the logFl
        (( ${#a[*]} > 0 )) && logFl=${a[0]}
}

#
# print banner with stars
#
function msg(){
	local cnt=${#1} ; local sline='' ; local c
	# create line of stars 4 longer than length of first argument to msg
	for ((c=1;c<=(cnt+4);c++)); { sline=${sline}'*'; }
	echo -e "\n\t${sline}\n\t* ${@}\n\t${sline}\n"
} # end msg()

# if cross day boundary, move logs
mvLogs
rotateLog
msg "Memory statistics $(date)" 2>&1 >${logFl}
msg "vmstat in MB of vm table" 2>&1 >>${logFl}
vmstat -S M -s 2>&1 >>${logFl}

# dump /proc files of interest
for t in vmstat meminfo slabinfo
{
        pt="/proc/${t}"
        msg "cat of ${pt}" 2>&1 >>${logFl}
        cat ${pt} 2>&1 >>${logFl}
}

# output ps -ef and dmesg if we are using more than 200 M of swap
if (( $(grep -i swap ${logFl} | grep -i use | awk '{printf("%d",$1)}') > 200 ))
then
	msg "Process listing" 2>&1 >>${logFl}
	ps -ef >> ${logFl}
	msg "dmesg output" 2>&1 >>${logFl}
	dmesg >> ${logFl}
fi
exit 0
