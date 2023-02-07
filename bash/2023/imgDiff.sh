#!/bin/bash
if [[ $# < 3 ]]
then
   echo "USAGE: ${0} <from mnt> <to mnt> <file to diff>"
   echo " For mounts, only the last path element, not full path."
   echo " For file, full path."
   exit 1
fi
FROM=${1}
TO=${2}
FILE=${3}

echo /mnt/${FROM}/${FILE} /mnt/${TO}/${FILE}
echo =======================================
sdiff -EsW -w 200 /mnt/${FROM}/${FILE} /mnt/${TO}/${FILE}
