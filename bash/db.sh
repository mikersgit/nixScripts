#!/bin/bash

# edit two files, one in the current directory and one in another tree
# that differs only by the branch name.
# mb == merge branch name (work in progress) [not a path]
# cb == current branch name (known good) [not a path]
# e.g.
# cb=bretDcnReg
# mb=dcnMrg
opts=""
while getopts :o:c:m:f: OPT; do
    case $OPT in
	o)
	opts="$OPTARG"
	;;c)
	cb="$OPTARG"
	;;m)
	mb="$OPTARG"
	;;f)
	fl="$OPTARG"
	;;*)
	echo -e "usage: ${0##*/} [-o <cmd options>] [-c <good branch>] [-m <merge branch>] [-f file]"
	exit 2
    esac
done
shift $[ OPTIND - 1 ]

if (( ${#cb} < 1 || ${#fl} < 1 ))
then
	echo "need 'cb' and 'mb' defined in path, and -f file"
	exit 1
fi

cbpth=$(pwd | sed s/${mb}/${cb}/ )

diff ${opts} ${cbpth}/${fl} ${fl}
