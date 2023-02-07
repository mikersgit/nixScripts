#!/bin/bash

# diff output files example
#  sdiff -w 200 31TO31or.txt 31orTO31.txt

if [[ $# < 2 ]]
then
  echo "${0}  <SrcDir> <DestDir> [-u]"
  exit 1
fi

SrcDir="${1}"
DestDir="${2}"
SrcNm=$(echo ${SrcDir}|sed -e 's/\///g' -e 's/mnt//')
DestNm=$(echo ${DestDir}|sed -e 's/\///g' -e 's/mnt//')
outFile=${SrcNm}2${DestNm}.txt

m=$(mount -t ext4 |grep ${SrcNm} |awk '{n=split($1,a,"\/");print a[n]" "$3}')
# default to "DryRun"
DR="n"
MSG="Show files that only exist in ${SrcDir}, or are different between the two."
SEP="================================================================================="

if [[ ${3} = "-u" ]]
then
    DR=""
    MSG="================= Update ${DestDir} with files from ${SrcDir}. ================="
	read -p "Update ${DestDir} from ${SrcDir}? N|[Y] " ans
    if [[ ${ans} != "Y" ]]
    then
       echo "NOT doing update"
       exit 1
    fi
fi
echo -e "${m}\n${MSG}" |tee ${outFile}
echo ${SEP}|tee -a ${outFile}
sleep 5
rsync --exclude=.bash_history --exclude="genesis*sqlite" -xrplcv${DR} ${SrcDir}/ ${DestDir}/ |tee -a ${outFile}

echo "Diff output in ========== ${outFile} =========="
if [[ ${#DR} > 0 ]]
then
    echo -e "Reverse direction of Diff\n${SEP}"
    outFile2=${DestNm}2${SrcNm}.txt
    m=$(mount -t ext4 |grep ${DestNm} |awk '{n=split($1,a,"\/");print a[n]" "$3}')
    MSG="Show files that only exist in ${DestDir}, or are different between the two."
    echo -e "${m}\n${MSG}" |tee ${outFile2}
    echo ${SEP}|tee -a ${outFile2}
    rsync --exclude=.bash_history --exclude="genesis*sqlite" -xrplcvn ${DestDir}/ ${SrcDir}/ |tee -a ${outFile2}

    echo "Diff output in ========== ${outFile2} =========="

    echo "============================"
    mount -t ext4 |grep mnt |awk '{n=split($1,a,"\/");print a[n]" "$3}'
    echo "============================"
    sdiff -w200 ${outFile} ${outFile2} |more
fi
