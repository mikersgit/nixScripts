#!/bin/bash

# command to generate diff for upload to review board
# the diff is made between the merge base revision (commit where branch made)
# and the head of the branch.
# the git diff command and other details are printed to be copy/paste into
# description of review request.
#

function usage() {
        echo "usage: ${0##*/} topics/myname/thebug /some/ouput/path/diff.out"
        echo
        exit 1
} # end usage()

#
# print banner with stars
#
function msg() {
	local cnt=${#1};local sline='';local c
	# create line of stars 4 longer than length of first argument to msg
	for ((c=1;c<=(cnt+4);c++)); { sline=${sline}'*'; }
	echo -e "\n\t${sline}\n\t* ${@}\n\t${sline}\n"
} # end msg()

# parameter checks
if (( $# < 2 )) || [[ $1 = -[h?] ]]
then
        usage
fi
DIFFOPTS='--full-index --patience -B -U20'
TRUNK='nas/trunk'
BRANCH=${1}
OUTPUT=${2}

# sanity check that git is OK
if ! git pull 2>/dev/null
then 
        msg "Not in a git repo: ${PWD}\n" "\t* git pull"
        usage
fi

if ! git checkout ${BRANCH} 2>/dev/null
then
        msg "Could not checkout branch: ${BRANCH}\n" "\t* git checkout ${BRANCH}"
        usage
fi

BRANCHg=$(git branch |grep ^\*| awk '{print $2}')
BASE=$(git merge-base ${BRANCHg} ${TRUNK})
HEAD=$(git rev-parse  ${BRANCHg}) 

echo -e "\n"
set -x
git diff ${DIFFOPTS} ${BASE}..${HEAD} > ${OUTPUT}
set +x

msg  "TRUNK:  ${TRUNK}                                       \n"\
 "\t* BRANCH: ${BRANCHg}\n"\
 "\t* BASE:   ${BASE}\n"\
 "\t* HEAD:   ${HEAD}\n"\
 "\t* OUTPUT: ${OUTPUT}"
