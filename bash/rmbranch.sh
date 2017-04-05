#!/bin/bash

# command to retire a branch for a bug.
# deletes the SVN branch and then recursively removes local
# working copy.
#####

# generic branch retire bug
: ${retireBug:='22208'}

SVNHOST='https://svn01.atlanta.hp.com/local/swd-usd-eng'
BRANCHBASE='/root/workspace'
BUG=''
SVNBRANCHBASE='branches/private/michael.roberts'

function usage() {
	echo "usage: ${1} [-b <bugNumber,bugNumber,...>] | "
        echo "            [-n Branch name]"
	exit 2
}
bopt=0;nopt=0
while getopts :b:n: OPT; do
    case $OPT in
	b)
	BUG="$OPTARG"
        Bname="bug${BUG}"
        bopt=1
	;;n)
	Bname="$OPTARG"
        nopt=1
	;;*)
	usage ${0##*/};;
    esac
done
shift $[ OPTIND - 1 ]

(( ! bopt && ! nopt )) && usage ${0##*/}

SVNTO="${SVNHOST}/${SVNBRANCHBASE}/${Bname}"
if ((bopt))
then
    MESSAGE="Bug: ${retireBug}
    Removing branch, work on bug ${BUG} complete" 
else
    MESSAGE="Bug: ${retireBug}
    Removing branch, ${SVNBRANCHBASE}/${Bname}"
fi
echo "Removing SVN branch ${SVNTO}"
if svn delete -m "${MESSAGE}" ${SVNTO}
then
	echo "Removing working copy ${BRANCHBASE}/${Bname}"
	rm -rf ${BRANCHBASE}/${Bname}
fi
