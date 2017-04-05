#!/bin/bash

# Script to gather system statistics while running CRR run-once task
#

#
# init variables
####
IBBASE='/usr/local/ibrix'
IBPATH=${IBBASE}'/bin'
IBLOG=${IBBASE}'/log'
CRRCMD=${IBPATH}'/ibrix_crr'
CRRCTL=${IBPATH}'/ibrcfrctl'
DAEMON='ibrcfrd'
s_fs='fs1_40'
t_fs='fs1_41'
t_cl='mwr1_cl'

# CRR run once command
CRRCMD_RO="${CRRCMD} -s -o -f ${s_fs} -C ${t_cl} -F ${t_fs}"

#
# check crr task status every 5 seconds until no tasks (assumes only one
# CRR task at a time)
#######
function local_crrwait(){
        local cnt=99
        while (( cnt > 0 ))
        do
                sleep 5
                cnt=$(${CRRCMD} -l | awk '$1 !~ /^TASK|----/ {print $1}'|wc -l)
        done
}

#
# echo message w/ time stamp H:M:S:nS
###
function msg() {
        local str=${@}
        local ts=$(date '+%T:%5N')
        delim='============================='
        echo -e "${delim}\n= ${ts}\n= ${str}\n${delim}\n"
}

# Start collectl gathering cpu (cC), disk (dD), inode (i), memory (m), network (nN),
#                          socket (s), tcp (t), process (Z) info
# filter the process info for 'ibrcfr' sample proc info every 2 seconds
##
cloc='/var/tmp/crr'
csubsys='cCdDimnNstZ'
pfilt='Cibrcfr'
nohup collectl -f ${cloc} --subsys ${csubsys} --procfilt ${pfilt} -i1:2 2>&1 &
cpid=$!
msg "Started collectl"

# clear the local fs
# wait for completion
[[ -d /${s_fs} ]] && rm -rf /${s_fs}/*

msg "Start CRR run once for deletes"
# runonce crr job to replicate the delete
${CRRCMD_RO}
local_crrwait
msg "End CRR run once for deletes"

# extract tar.bz
msg "Start tar extract"
cd /${s_fs}
tar -jxf /var/usr.tar.bz
cp /var/usr.tar.bz /${s_fs}
msg "End tar extract"

# create files w/ dd
msg "Start medium create"
~/bin/medium.sh /${s_fs}
msg "End medium create"

# runonce crr job
msg "Start CRR run once for data"
${CRRCMD_RO}
local_crrwait
msg "End CRR run once for data"

# allow some drain time to capture data w/o CRR load
sleep 5

# stop collectl
kill ${cpid}
msg "Stopped collectl"
ls -lrt ${cloc}* | tail -1

####################################################################################################
# Example analysis
# collectl -oT -sm -p /var/tmp/crr-mwr0lmvm1-20110701-114615.raw.gz |less
# collectl -oT -sZ -p /var/tmp/crr-mwr0lmvm1-20110701-114615.raw.gz |less
# collectl -oT -sZ --procopts m -p /var/tmp/crr-mwr0lmvm1-20110701-114615.raw.gz |less
# collectl -oT -sZ --procopts n -p /var/tmp/crr-mwr0lmvm1-20110701-114615.raw.gz |less
# collectl -oT -sZ --procopts c -p /var/tmp/crr-mwr0lmvm1-20110701-114615.raw.gz |less
# collectl -oT -sZ --procopts i -p /var/tmp/crr-mwr0lmvm1-20110701-114615.raw.gz |less
# collectl -oT -sD -p /var/tmp/crr-mwr0lmvm1-20110701-120548.raw.gz | less
# collectl -oT -sD --dskfilt sd[ac],dm-[03] -p /var/tmp/crr-mwr0lmvm1-20110701-120548.raw.gz | less
# collectl -oT -sc -p /var/tmp/crr-mwr0lmvm1-20110701-120548.raw.gz | less
# collectl -oT -sC -p /var/tmp/crr-mwr0lmvm1-20110701-120548.raw.gz | less
# collectl -oT -sN --netfilt eth0 -p /var/tmp/crr-mwr0lmvm1-20110701-130828.raw.gz |less
