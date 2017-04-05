#!/bin/bash

# Invoke the ibrcfrworker directly, outside of FM control

function usage() {
	echo "usage: ${1} [-t IP ] [-m module] [-p password] [-?h]"
        echo -e "\t -t IP       Target cluster node IP address"
        echo -e "\t -m module   Source file system name (no slashes)"
        echo -e "\t -p password Target cluster node root password"
        exit 2
} # end usage()

if (( $# <2 ))
then
        usage ${0##*/} 
fi

while getopts :t:m:p:?h OPT; do
    case $OPT in
	t)
	TARG="$OPTARG"
	;;m)
	MODULE="$OPTARG"
	;;p)
	RPASS="$OPTARG"
	;;?)
	
	;;h)
	
	;;*)
	echo "usage: ${0##*/} [-t ARG] [-m ARG] [-p ARG] [-?h]"
	exit 2
    esac
done
shift $[ OPTIND - 1 ]

BIN='/usr/local/ibrix/bin'

# individual node IP, NOT cluster VIP
#TARG=10.30.244.32
TARG=${1}
RPASS='hpinvent'

# this is the symbolic name in the /etc/ibrix/engine/ibrcfrworker.conf file
# for the target file system
# for our purposes we've made it the same as the name of the SOURCE file system
#
#MODULE=fs2_f4
MODULE=${2}

HOSTNM=$(hostname)
FILTERMNT='/mnt/crr/filter/'${MODULE}/${HOSTNM}'/'

export RSYNC_PASSWORD=${RPASS}

${BIN}/ibrcfrworker --port=9202 \
                    --hard-links \
                    -WaAX \
                    --log-format="%t,<%p>,%i,%n%L" \
                    --stats --itemize-changes \
                    --modify-window=1 --bwlimit=0 \
                    --inplace \
                    ${FILTERMNT} \
                    ${TARG}::${MODULE}
