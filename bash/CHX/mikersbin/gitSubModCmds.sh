#!/bin/bash
# checkout, pull, status that are sensitive to the wheather or not you are in a git submodule or not
# if in the main repo (NOT submodule) do not recurse the submodules
# Assumes links to gitSubModCmds.sh like:
#  ln gitSubModCmds.sh gch
#  ln gitSubModCmds.sh gpl
#  ln gitSubModCmds.sh gst
#  ln gitSubModCmds.sh gbr
#  ln gitSubModCmds.sh gtg
##################

LINKS=(gch gpl gst gbr gtg)
MAINCMD="gitSubModCmds.sh"

CMD=${0##*/}
BRANCH=${1}
TOPREPO="Winchester_MS"
ISSUBMODULE=1
gchkopt=""
gplopt=""
gstopt=""
BASEDIR="${PWD%%/Winchester_MS*}"

if [[ ${#BRANCH} -gt 1 ]] && [[ ${BRANCH} = "MAKELINKS" ]] ;then
	lnkcnt=0
	lnkmsg="links"
	for l in ${LINKS[*]}
	{
		if [[ ${MAINCMD} -ef ${l} ]] ;then
			echo "Link ${l} already exists"
		else
			((lnkcnt+=1))
			echo "Creating hard link ${l}"
			ln ${MAINCMD} ${l}
		fi
	}
	[[ ${lnkcnt} -eq 1 ]] && lnkmsg="link"
	echo "${lnkcnt} $lnkmsg created"
	exit 2
fi

function getBranch() {
	if [[ ${ISSUBMODULE} == 1 ]] ;then
		git branch
	else
		echo "===== ${TOPREPO} =====" 
		git branch
		for ridx in $(seq 0 ${smidx})
		{
			echo "===== ${sm[$ridx]} =====" 
			cd ${sm[$ridx]}
			git branch
			cd ${BASEDIR}/${TOPREPO} > /dev/null
		}
	fi
}

function getStatus() {
	if [[ ${ISSUBMODULE} == 1 ]] ;then
		git status |grep -v -e ^$ -e ^nothing
	else
		echo "===== ${TOPREPO} =====" 
		git status ${gstopt} |grep -v -e ^$ -e ^nothing
		for ridx in $(seq 0 ${smidx})
		{
			echo "===== ${sm[$ridx]} =====" 
			cd ${sm[$ridx]}
			git status |grep -v -e ^$ -e ^nothing
			cd ${BASEDIR}/${TOPREPO} > /dev/null
		}
	fi
}

function getPull() {
	if [[ ${ISSUBMODULE} == 1 ]] ;then
		git pull 
	else
		echo "===== ${TOPREPO} =====" 
		git pull ${gplopt}
		for ridx in $(seq 0 ${smidx})
		{
			echo "===== ${sm[$ridx]} =====" 
			cd ${sm[$ridx]}
			git pull
			cd ${BASEDIR}/${TOPREPO} > /dev/null
		}
	fi
}

function getCheckout() {
	if [[ ${ISSUBMODULE} == 1 ]] ;then
		git checkout ${BRANCH} 
	else
		echo "===== ${TOPREPO} =====" 
		git checkout ${BRANCH} ${gchkopt}
		for ridx in $(seq 0 ${smidx})
		{
			echo "===== ${sm[$ridx]} =====" 
			cd ${sm[$ridx]}
			git  checkout ${BRANCH}
			cd ${BASEDIR}/${TOPREPO} > /dev/null
		}
	fi
}

function getTag() {
	if [[ ${ISSUBMODULE} == 1 ]] ;then
		git tag --list
	else
		echo "===== ${TOPREPO} =====" 
		git tag --list
		for ridx in $(seq 0 ${smidx})
		{
			echo "===== ${sm[$ridx]} =====" 
			cd ${sm[$ridx]}
			git tag --list
			cd ${BASEDIR}/${TOPREPO} > /dev/null
		}
	fi
}

if [[ -e .gitmodules ]] ;then
	ISSUBMODULE=0
	gchkopt="--no-recurse-submodules"
	gplopt="--recurse-submodules=no"
	gstopt="--ignore-submodules"
	sm=($(awk '{if($1=="path") print $3}' .gitmodules))
	((smidx=${#sm[*]}-1))
	repos=($TOPREPO ${sm[*]})
fi

case $CMD in
	gch) 
		if [[ ${#BRANCH} -lt 1 ]] ; then
			echo "Need to provide branch to checkout"
			echo "$CMD <branch>"
			exit 1
		fi
		getCheckout
		;;
	gpl)
		getPull
		;;
	gst)
		getStatus
		;;
	gbr)
		getBranch
		;;
	gtg)
		getTag
		;;
	${MAINCMD})
		echo "Do not execute ${MAINCMD} directly, use one of the command links:"
		for l in ${LINKS[*]}
		{
			echo "${l}"
		}
		echo "or create the links by calling:"
		echo "${MAINCMD} MAKELINKS"
		exit 1
		;;
	*)
		echo "Not a recognized command. valid options:"
		echo "	gch <branch> {git checkout}"
		echo "	gpl	     {git pull}"
		echo "	gst	     {git status}"
		echo "	gbr	     {git branch}"
		echo "	gtg	     {git tag}"
		exit 1
	;;
esac
