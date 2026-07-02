#!/bin/bash
# checkout the main repo and submodules to the same branch

TARGETBRANCH=${1}
repos=(Winchester_MS AdaptiveServiceCore ConfigurationService HistoryService IOBrokerService ModbusService RodLiftService VFDService WebClient)
TOPBR=${repos[0]}
CURDIR=${PWD##*/}

if [[ ${#TARGETBRANCH} -lt 1 ]] ;then
	echo "Provide branch name"
	echo "${0##*/} dev"
	exit 1
fi
if [[ $TOPBR != $CURDIR ]] ;then
	cd ${TOPBR}
fi

echo "============= $TOPBR ============="
git pull --recurse-submodules=no
git checkout ${TARGETBRANCH}

((maxbranch=${#repos[*]}-1))
for i in $(seq 1 ${maxbranch})
{
	echo "============= ${repos[$i]} ============="
	cd Services/${repos[$i]}
	git pull --recurse-submodules=no
	git checkout ${TARGETBRANCH}
	cd - >/dev/null
}
