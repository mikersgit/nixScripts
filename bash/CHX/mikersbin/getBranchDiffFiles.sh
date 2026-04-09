#!/bin/bash
# output of 'git diff --name-status <branchName>'
if [[ ${#} -lt 1 ]] ;then
	echo "Provide branch name against which to diff"
	echo "eg. ${0##*/} master"
	git branch
	exit 1
fi
BRANCH=${1}
CURRENT_VIEW=$(git branch |grep "^\*"|cut -d" " -f2)
git diff --name-status $BRANCH | while read status path rename
do
	case $status in
	R*) suffix="RENAME"
		Rdir=${rename%/*}
		Rfile=${rename##*/} ;;
	M) suffix="MODIFY";;
	A) suffix="DELETE";;
	D) suffix="ADD";;
	*) suffix="UNKNOWN";;
	esac

	Dfile=${path##*/}
	DOUTfile=${Dfile}"."${suffix}
	Ddir=${path%/*}
	# if file is in the top level directory, no parent path
	if [[ ${Ddir} = ${Dfile} ]]
	then
		Ddir="."
	fi

	case $suffix in
	RENAME) touch ${Rdir}/${Dfile}"RENAME"${Rfile} ;;
	MODIFY) git show ${BRANCH}:${Ddir}/${Dfile} > ${Ddir}/${DOUTfile} ;;
	DELETE) touch ${Ddir}/${DOUTfile} ;;
	ADD) mkdir -p ${Ddir}
		git show ${BRANCH}:${Ddir}/${Dfile} > ${Ddir}/${DOUTfile};;
	UNKNOWN) ;;
	esac

done

find . -type f -regextype posix-extended -regex '.*(MODIFY|DELETE|ADD)$'
find . -type f -name \*RENAME\*
git status
echo "ADD: files exist in ${BRANCH} but not in ${CURRENT_VIEW}"
echo "DELETE: files exist in ${CURRENT_VIEW}, but not in ${BRANCH}"
echo "RENAME: identical files exist in ${BRANCH} and ${CURRENT_VIEW}, but with different names"
