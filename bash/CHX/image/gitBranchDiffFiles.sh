#!/bin/bash
# diff files from branch $1 of files in infile
# use input from git diff --name-only <branch>
BRANCH=${1}
for f in $(git diff --name-only $BRANCH)
do
	localf=${f##*current/}
	if [ ! -e ${localf} ] ;then
		continue
	else
		read -p "get ${localf} N|[Y]" ans
		if [[ $ans = [nN] ]] ;then
			:
		else
			git show ${BRANCH}:${f} >${localf}"-${BRANCH}"
		fi
	fi
done
