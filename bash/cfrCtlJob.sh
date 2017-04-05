#!/bin/bash

# script to query the local FSN for active and past CRR job info using ibrcfrctl command
#

BIN='/usr/local/ibrix/bin'
LDIR='/var/log/cfr'
DAEMON='ibrcfrd'
CFRCTL="${BIN}/ibrcfrctl"
JBSTAT='job.status'
PORT=""
ActiveJobs=''
PastJobs=''

hline='\n\t##########'
hline1='\n\t#######################'
eline='\n================================='
elineL='\n==========================================================='

#
# translation of status codes from "include/ibrcfr_common.h"
#
function statCodes(){
   echo -e "${eline}\n= STATUS code legend${eline}"
   echo '0 == JOB_SUBMITTED,          // job is submitted'
   echo '1 == JOB_RUNNING,            // job is running'
   echo '2 == JOB_PAUSED,             // job is paused'
   echo '3 == JOB_STOPPING_STAGE1,    // stopping job initiated and going on'
   echo '4 == JOB_STOPPING_STAGE2,    // 2nd stage in job stop process'
   echo '5 == JOB_STOPPED,            // job is stopped and wait be recycled'
   echo
}

# get port on which ibrcfrd is listening
# report if no daemon is found
#
PID=$(pgrep ${DAEMON})
if (( ${#PID} )) 
then
        DCMD=$(ps -o args -p ${PID}|tail -1) 
        PORT=$(echo ${DCMD} | awk '$0 ~ /port/ {c=split($NF,a,"="); print a[c]}')
        echo -e "${elineL}\n= ${DAEMON} pid ${PID}, listening on port ${PORT}\n= ${DCMD}${elineL}\n"
else
        echo -e "${eline}\n= NO ${DAEMON} process found!\n= Reporting historical tasks only.${eline}\n"
fi

# if there is a running ibrcfrd, get list of jobs that ibrcfrd shows as active
#
[[ -x ${CFRCTL} ]] && (( ${#PORT} )) && declare -a ActiveJobs=( $(${CFRCTL} --port=${PORT} --op=list |
                      awk '$0 ~ /job id/ {sub(",","",$3);print $3}') )

# get list of all continuous jobs
# will filter later for past v. active
#
if ! \ls -d ${LDIR}/[[:digit:]]* >/dev/null 2>&1
then
        echo -e "${eline}\n= NO CRR task directories!\n= No historical tasks to display.${eline}\n"
else
        declare -a PastJobs=($(\ls -d ${LDIR}/[[:digit:]]* |
                    awk '{gsub("/"," ");printf("%s ",$NF)}'))
fi

#
# for a particular job id, print inquiry, status file, previous status file,
# and config information
# only attempt to contact the daemon if PORT could be determined.
#
function printJob() {
        local jstatfile="${LDIR}/${j}/${JBSTAT}"
        local prevjstatfile="${LDIR}/${j}/${JBSTAT}.bak"

    if (( ${#PORT} ))
    then
        echo -e "${hline}\n\t# JOB ${j}${hline}\n"
        ${CFRCTL} --port=${PORT} --op=inquiry --jobid=${j}
    fi

    echo -e "${hline1}\n\t# Current status${hline1}\n"
    ${CFRCTL} --op=checkstatfile --statfile=${jstatfile}

    echo -e "${hline1}\n\t# Previous status${hline1}\n"
    ${CFRCTL} --op=checkstatfile --statfile=${prevjstatfile}

    (( ${#PORT} )) && ${CFRCTL} --dip localhost --port=${PORT} --op inqconf --jobid=${j}

}

# filter active jobs out of the list
# Assumes that $1 is set by the caller to the job id to check
#
function isActiveJob() {
        local jid=${1}
    for i in ${ActiveJobs[*]}
    {
	if (( jid == i ))
	then
	    return 0
	fi
    }
    return 1
}

# output status code legend if there are any jobs to display
if [[ -n ${ActiveJobs[*]} ]] || [[ -n ${PastJobs[*]} ]]
then
        statCodes
else
        exit 0
fi

if [[ -n ${ActiveJobs[*]} ]]
then
        eline='\n=========================='
        echo -e "${eline}\n= Active Continuous jobs${eline}\n"

        # loop through job ids of active jobs
        #
        for j in ${ActiveJobs[*]}
        {
                printJob
        }
fi

if [[ -n ${PastJobs[*]} ]]
then
        echo -e "${eline}\n= Past continuous jobs${eline}\n"

        # loop through job ids of all jobs. if the job is not in the active job list
        # then print info about it
        #
        for j in ${PastJobs[*]}
        {
                if ! isActiveJob ${j}
                then
	                printJob
                fi
        }
fi
