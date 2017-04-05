#!/bin/bash

# using the standard cloning user and password make a bug a 'Master'
# and then make clones based on the conf file
#
###############
prog=${0##*/}
function usage() {
	echo "$prog [-D] bugnumber bugTargetFile"
	echo 'export DEBUG=1' to get shell debug info
	exit 2
}

(( DEBUG )) && set -x
(($# < 2)) && usage
if (($# == 3))
then
	export DEBUG=1
	export LOG_LEVEL=debug
	set -x
	shift
fi
bug=$1
conf=$2

export cluser=BugzillaCloningAutomation@hp.com
export clpass=CloningBugsIsFun!

bugTls="${HOME}/hp-smb-tools/hp-bugs"
mkMaster="${bugTls}/hpConvertToMaster.py"
mkClones="${bugTls}/hpMasterBug.py"

# avoid seeing password whining from python
if ((! DEBUG)) 
then
	exec 2>/dev/null
fi
echo ${clpass}
# try to make a master first, then clone
echo ${clpass} | ${mkMaster} ${cluser} ${bug}
echo ${clpass} | ${mkClones} ${cluser} ${bug} ${conf}
