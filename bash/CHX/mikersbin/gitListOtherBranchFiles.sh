#!/bin/bash
PROG=${0##*/}
if [[ ($# -lt 1 && ${#branch} -eq 0 ) ]]
then
	echo "$PROG <Branch>"
	echo "or export branch=<branch name>, $PROG"
	exit
fi
if [[ $# -eq 1 ]]
then
	BRANCH=$1
else
	BRANCH=$branch
fi
git ls-tree --name-only -r ${BRANCH}
