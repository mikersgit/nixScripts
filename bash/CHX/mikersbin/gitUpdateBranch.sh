#!/bin/bash
MASTER=$1
BRANCH=$2

if [[ $# < 2 ]]
then
	echo "${0##*/} MASTER BRANCH"
	echo "	Updates the contents of BRANCH with the contents of MASTER"
	echo "	Good to bring in changes from MASTER that are NOT related"
	echo "	to the changes in BRANCH"
	echo "	use 'git checkout BRANCH && git merge MASTER' if changes overlap"
	exit 1
fi
echo "rebase ${BRANCH} to ${MASTER}"
echo "this preserves changes in $BRANCH, and layers on changes from $MASTER"
echo "ONLY do this if the changes in $MASTER are UNRELATED to the changes in $BRANCH"

read -p "continue? [N]|Y" ans

if [[ $ans = [yY] ]]
then
	git checkout -f ${MASTER}
	git pull
	git checkout -f ${BRANCH}
	git rebase ${MASTER}
fi
