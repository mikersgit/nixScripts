#!/bin/bash

function usage() {
	echo "$0 <BRANCH> [<FILE>]"
	echo "or export branch=<branch name>, $0 <File>"
	exit
}

if [[ $# -eq 0 && ${#branch} -eq 0  ]]
then
	usage
fi
if [[ $# -eq 2 ]]
then
	BRANCH=$1
	FILE=$2
elif [[ ${#branch} -gt 1 ]]
then
	BRANCH=$branch
	FILE=$1
else
	usage
fi

# ignore white space in diff
git diff -b ${BRANCH} ${FILE}
