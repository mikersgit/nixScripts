#!/bin/bash

# script to rsync legacy dogfood server home_dirs to ldap test dogfood server
#
# could start using '--max-delete=1' to avoid deleting files on the ldap test server
#

srcDir='/home_dirs'
trgDir='/dogfood/home'
trgIP='16.125.127.90'
logFlBase="/var/rsyncDF_2${srcDir##*/}.log"
logFl=${logFlBase}

RSYNC='/usr/bin/rsync'
RSYNC_OPTS='-xHavXA'

#
# print banner with stars
#
function msg(){
	local cnt=${#1}
	local sline=''
	# create line of stars 4 longer than length of first argument to msg
	for ((c=1;c<=(cnt+4);c++)); { sline=${sline}'*'; }
	echo -e "\n\t${sline}\n\t* ${@}\n\t${sline}\n"
} # end msg()

# check the date on the semaphore file. if it is 2 days old or older, then
# remove the semaphore so that in the next pass it will get replicated.
#
function checkSemFile() {
	local tsFile=/var/2day
	local semFile=${1}
	touch --date=now-2day ${tsFile} 
	semFileDate=$(\ls -l --time-style '+%Y%m%d%H%M%S' ${semFile} |
		      awk '{print $6}')
	tooOld=$(\ls -l --time-style '+%Y%m%d%H%M%S' ${tsFile} |
		  awk '{print $6}')
	if (( semFileDate <= tooOld ))
	then
		msg "Removing old semaphore file ${semFile} ."
		\rm -f ${semFile}
	fi
	\rm -f ${tsFile}
} # end checkSemFile()

#
# rotate logs
# set the current log file to be the oldest in the list
#
# TODO:
# if files to rotate do not exist something like the following could be done
# to create four files through which to rotate:
# for d in 1 2 3 4
# {
#       touch -t $(date -d "yesterday + ${d} hour" '+%Y%m%d%H%M') ../foo.${d}
# }
function rotateLog() {
        local flPattern="${logFlBase}.[[:digit:]]"
        declare a=($(ls -lrt ${flPattern} 2>/dev/null|awk '{print $NF}'))

        # make sure there was content before resetting the logFl
        (( ${#a[*]} > 0 )) && logFl=${a[0]}
}

# set the oldest log to be the current log
# file name is of the form logfile.log.N where N=integer
# currently there are 1-4
rotateLog

msg "Start $(date)" > ${logFl}
cd ${srcDir}
for d in $(ls -ld *|awk '$1 ~ /^d/{print $NF}')
{
        semFile="${srcDir}/${d}/.rsyncInProgress"
        if [[ ! -f ${semFile} ]]
        then
                echo $(date) > ${semFile}
                msg "${srcDir}/${d}" >> ${logFl}
                ${RSYNC} ${RSYNC_OPTS} ${d} ${trgIP}:${trgDir} 2>&1 >> ${logFl}
                \rm -f ${semFile}
	else
		# delete semaphore files older than 2 days
		checkSemFile ${semFile}
        fi
}
msg "Done $(date)" >> ${logFl}
