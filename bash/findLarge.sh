#!/bin/bash

# list the sizes of all the subdirectories of the current directory

# list the directories
function dirList() {
    ls -ld * 2>/dev/null |grep ^d | awk '{print $NF}'
}

echo -e "\nDirectories in ${PWD} that are > 1 MB in size.\n"
for d in $(dirList)
{
    du -hs ${d}
    here=$PWD
    cd ${d}
    for sd in $(dirList)
    {
        cd ${here}
        du -hs ${d}/${sd}
        cd ${d}
    }
    cd ${here}
} | awk '$1 ~/M$|G$/ {print}'
