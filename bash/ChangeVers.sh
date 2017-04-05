#!/bin/bash

# using the standard cloning user and password make clones for the master
# based on the conf file
#
###############
prog=${0##*/}
function usage() {
	echo "$prog bugnumber bugTargetFile"
	echo 'export DEBUG=1' to get shell debug info
	exit 2
}

(( DEBUG )) && set -x
(($# < 2)) && usage
bug=$1
conf=$2

export cluser=BugzillaCloningAutomation@hp.com
export clpass=CloningBugsIsFun!
bugTls="${HOME}/hp-smb-tools/hp-bugs"
chVers="${bugTls}/hpChangeVersion.py"
#mkClones="${bugTls}/hpMasterBug.py"

# avoid seeing password whining from python
if ((! DEBUG)) 
then
	exec 2>/dev/null
fi

echo ${clpass} | ${chVers} ${cluser} ${bug} ${conf}
