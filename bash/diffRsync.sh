#!/bin/bash

# Script to generate diffs between downloaded rsync tar ball and
# ibrcfrworker
# assumes it is being run in ibrcfrworker/
# run like "diffRsync.sh 2>&1 | tee ../rsyncDiff.out"
###############

rsyncDir='/root/rsync-3.0.6'
for f in $( find . ! -path \*.svn\*)
{
        if [[ ! -e ${rsyncDir}/${f} ]]
        then
                echo ${rsyncDir}/${f} not found in download
        else
                if [[ ! -d ${f} ]]
                then
                        echo "diff ${f} ${rsyncDir}/${f}"
                        diff ${f} ${rsyncDir}/${f}
                fi
        fi
}
