#!/bin/bash

JNUM=$1
IBPATH='/usr/local/ibrix/bin'
IBCRRJOB=${IBPATH}/'ibrix_crr'
TSKPFX='crr'

if [[ ! -f ${IBCRRJOB} ]]
then
        IBCRRJOB=${IBPATH}/'ibrix_cfrjob'
        TSKPFX='cfr'
fi

if (( $# < 1))
then
	echo "usage: ${0##*/} [JobNumber] | [a]"
	${IBCRRJOB} -l
	exit 2
fi

if [[ ${JNUM} = [a] ]]
then
	# kill all jobs
	JNUM=$(${IBCRRJOB} -l |grep ^${TSKPFX} |awk '{sub("'${TSKPFX}'-","",$1);printf("%d ",$1)}')
fi

#list jobs before kill
${IBCRRJOB} -l

for J in ${JNUM}
{
	# have to kill twice until persistent task mechanism is fixed
	${IBCRRJOB} -k -n ${TSKPFX}-${J}
	sleep 3
	${IBCRRJOB} -k -n ${TSKPFX}-${J}
}

#list jobs after kill
${IBCRRJOB} -l
