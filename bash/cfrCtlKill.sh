#!/bin/bash

# use ibrcfrctl to kill in event FM not working
PORT=$(ps -o args -p $(pgrep ibrcfrd) |awk '$0 ~ /port/ {c=split($NF,a,"="); print a[c]}')

ID=${1}
BIN='/usr/local/ibrix/bin'
DCMD="${BIN}/ibrcfrctl"

if (( $# < 1 ))
then
        # list jobs ibrcfrctl 
        echo -e "IDs of task available to kill\n ID \n====\n"
        ${DCMD} --port ${PORT} --op list | awk '$0 ~ /job id/ {sub(",","");print $3}'
else
        echo "Killing task ${ID}"
        ${DCMD} --port=${PORT} --op=stop --jobid=${ID}
fi

# kill this way may leave the FM confused. below is a way to remove traces of task
# 0) On the active FM put passive FMs in maint. ibrix_fm -m maintenance -A
# 1) On all nodes: /etc/init.d/ibrix_fusionmanager stop
# 2) On all nodes: delete the task*.xml files in /usr/local/ibrix/scheduler, i.e., cfr*.xml. Rebalance*.xml, etc.
# 3) On all nodes: delete /usr/local/ibrix/tmp/fmbackup.zip
# 4) On all nodes: /etc/init.d/ibrix_fusionmanager start
# 5) On all passive nodes: /ibrix_fm -m passive 
