#!/bin/bash

if [[ ($# -lt 2 && ${#branch} -eq 0 ) || $# -eq 0 ]]
then
	echo "$0 <Branch> <File>"
	echo "or export branch=<branch name>, $0 <File>"
	exit
fi
if [[ $# -eq 2 ]]
then
	BRANCH=$1
	FILE=$2
else
	BRANCH=$branch
	FILE=$1
fi
DelimCnt=$(echo ${FILE} |grep -c "\.")
if [[ ${DelimCnt} -gt 0 ]]
then
	FN=$(echo ${FILE} |cut -d "." -f1)
	FX="."$(echo ${FILE} |cut -d "." -f2)
else
	FN=${FILE}
	FX=""
fi
cp ${FILE} ${FN}-PREV${FX}
git checkout ${BRANCH} ${FILE}
vimdiff ${FILE} ${FN}-PREV${FX}

read -p "remove  ${FN}-PREV${FX} [N]|Y? " ans
if [[ $ans = [Yy] ]]
then
	rm  ${FN}-PREV${FX}
fi
