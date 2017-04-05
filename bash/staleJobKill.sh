#!/bin/bash

function usage() {
  echo "usage: ${1} -a VIP -p 'passiveIP1 passiveIP2'"
  exit 2
}

(( ${#} == 0 )) && usage ${0##*/}

while getopts a:p:h? OPT
do
        case ${OPT} in
                a) active=${OPTARG};;
                p) passive="${OPTARG}";;
                *) usage ${0##*/};;
        esac        
done

IBRbin='/usr/local/ibrix/bin'
# kill this way may leave the FM confused. below is a way to remove traces of task
# 0)
echo 'On the active FM put passive FMs in maint.'
ssh -q  ${active} "${IBRbin}/ibrix_fm -m maintenance -A"

# 1)
for i in ${active} ${passive}
{
   echo "Stop FM on ${i}"
   ssh -q  ${i} "/etc/init.d/ibrix_fusionmanager stop"
   # 2) On all nodes: delete the task*.xml files in /usr/local/ibrix/scheduler,
   #    i.e., cfr*.xml. Rebalance*.xml, etc.
   echo "remove crr schedule files on ${i}"
   ssh -q  ${i} "rm -f /usr/local/ibrix/scheduler/crr*xml"
   # 3) On all nodes: delete
   echo "remove FM backup db on ${i}:"
   ssh -q  ${i} " rm -f /usr/local/ibrix/tmp/fmbackup.zip"
}

# 4) On all nodes start FM:
for i in ${active} ${passive}
{
        echo "Start FM on ${i}"
        ssh -q  ${i} "/etc/init.d/ibrix_fusionmanager start"
}

# 5) On all passive nodes: /ibrix_fm -m passive 
for p in ${passive}
{
        echo "Set FM mode to passive on ${p}"
        ssh -q  ${p} "${IBRbin}/ibrix_fm -m passive"
}
