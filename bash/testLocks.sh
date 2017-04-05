#!/bin/bash

## script to demonstrate replication of an open file with an active flock("", LOCK_EX)

sleepint=60
lckfile='lockfile'$$

echo -e "\nWrite locking : ${lckfile} for ${sleepint} seconds.\n"

#
# aquire write lock and sleep in the background
#
( if flock -x ${lckfile} -c "sleep ${sleepint}" 
then
    : # do nothing if success
else
    echo "UN-Successful in locking : ${lckfile}"
fi ) &

#
# show flock is active on the file
#
fpid=$(pgrep flock)
pgrep -l flock
sleep 2
echo "fpid: ${fpid} open file descriptors"
ls -l /proc/${fpid}/fd

echo -e "\nprocesses with ${lckfile} open:"
lsof ${lckfile}

#
# verify flock is active on the file by trying to get a non-blocking lock
#
if flock -xn ${lckfile} -c "sleep 1" 
then
    echo -e "\nOOOPS! Successfully locked : ${lckfile}, should have been locked already! exiting"
    exit 2
else
    echo -e "\nConfirmed lock on: ${lckfile}"
fi

#
# do some IO 
#
echo -e "Adding content to : ${lckfile}\nWhile PID ${fpid} (flock) has write lock\n" >> ${lckfile}
cat ${lckfile}
echo "Shortly the file ${lckfile} on the replica should have the above message even though the file is open with write lock."

#
# verify original flock released by getting a new lock on the file
#
if flock -x ${lckfile} -c "sleep 2" 
then
    echo "Lock released and Successfully re-locked : ${lckfile}"
else
    echo "UN-Successful in locking : ${lckfile}"
fi
