#!/bin/bash
fpath=${1}/${3}
dpath=${2}/${3}
if [[ ${#} < 3 ]]
then
   echo "USAGE: ${0} <mnt path 1> <mnt path 2> <file to compare>"
   echo "   eg. ${0} /mnt/rimg /mnt/timg etc/fstab"
   exit 1
fi
echo "============================"
mount -t ext4 |grep mnt |awk '{n=split($1,a,"\/");print a[n]" "$3}'
echo "============================"
ls -l ${fpath} ${dpath}
md5sum  ${fpath} ${dpath}
echo  "=================="
echo  "${fpath}	 ${dpath}"
echo  "=================="
if grep a ${fpath} |grep -q ^Binary
then
    echo "${fpath} is Binary"
    exit
fi
sdiff -EsW -w 200 ${fpath} ${dpath}

