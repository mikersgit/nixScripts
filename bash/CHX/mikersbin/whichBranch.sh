#!/bin/bash
# get the current branch of the main repo and the submodules

repos=(Winchester_MS AdaptiveServiceCore ConfigurationService HistoryService IOBrokerService ModbusService RodLiftService VFDService WebClient)
TOPBR=${repos[0]}
CURDIR=${PWD##*/}

if [[ $TOPBR != $CURDIR ]] ;then
	cd ${TOPBR}
fi

echo "============= $TOPBR ============="
git branch
((maxbranch=${#repos[*]}-1))
for i in $(seq 1 ${maxbranch})
{
	echo "============= ${repos[$i]} ============="
	cd Services/${repos[$i]}
	git branch
	cd - >/dev/null
}
