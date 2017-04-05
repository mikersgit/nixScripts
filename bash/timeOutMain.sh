#!/bin/bash
#experiment with timer to kill background process
#
((DEBUG)) && set -x
function alarm(){
    sleep 5
    if ps -o args -p ${forkedProc} 2>&1 >/dev/null
    then
        ((DEBUG)) && echo "kill process ${forkedProc}"
        kill ${forkedProc} 
    else
        ((DEBUG)) && echo "no kill"
    fi
}

#call script that sleeps forever in background
backgroundSleep.sh ${1}&
forkedProc=$!
alarm
