#!/bin/bash
img=$1
mnt=$2
if [[ $# < 2 ]]
then
   echo "USAGE: ${0} <image path> <mount pt path>"
   exit 1
fi
mount -o offset=1048576 ${img} ${mnt}
df -h
