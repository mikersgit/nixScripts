#!/bin/bash

# command to create a branch for a bug.
# creates the SVN copy and then checks out a local
# working copy.
#####

SVNHOST='https://svn01.atlanta.hp.com/local/swd-usd-eng'
BRANCHBASE='/root/workspace'
BUG='22208'
SVNBRANCHBASE='branches/private'

function usage() {
	echo "usage: ${1} [-b <bugNumber> |-n <branch name>] [-u <user.name>]"
        echo "                  [-f branch from]"
	exit 2
}
BASE='trunk/fmt_0'
bopt=0;nopt=0
while getopts :b:n:u:f: OPT; do
    case $OPT in
	b)
	BUG="$OPTARG"
        Bname="bug${BUG}"
        bopt=1
	;;n)
	Bname="$OPTARG"
        nopt=1
        ;;f) BASE="${OPTARG}"
	;;u)
	svnUSER="$OPTARG"
        SVNBRANCHBASE=${SVNBRANCHBASE}'/'${svnUSER}
	;;*)
	usage ${0##*/};;
    esac
done
shift $[ OPTIND - 1 ]

(( ! bopt && ! nopt )) && usage ${0##*/}
if (( bopt && nopt ))
then
    echo "Only use 'b' or 'n', not both."
   usage ${0##*/}
fi

SVNFROM="${SVNHOST}/${BASE}"
SVNTO="${SVNHOST}/${SVNBRANCHBASE}/${Bname}/fmt_0"
if ((bopt))
then
    MESSAGE="Bug: ${BUG}
    Creating branch for work on bug ${BUG}"
else
    MESSAGE="Bug: ${BUG}
    Creating branch ${SVNBRANCHBASE}/${Bname}"
fi

WCOPY="${BRANCHBASE}/${Bname}"

[[ ! -d ${WCOPY} ]] && mkdir -p ${WCOPY}

if svn copy -m "${MESSAGE}" \
	--parents ${SVNFROM} \
	${SVNTO}
then	
    cd ${WCOPY}
    svn co ${SVNTO}
fi
