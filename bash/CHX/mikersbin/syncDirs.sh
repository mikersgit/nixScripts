#!/bin/bash

frmDir=${1}
toDir=${2}
if [ $# -lt 2 ]
then
   echo "USAGE: ${0} <from Dir> <to Dir>"
   echo "eg. ${0} /build/rootfs /mnt/timg"
   exit 1
fi
rsync --exclude=.bash_history --exclude="genesis*sqlite" -xrplcv ${frmDir} ${toDir}
