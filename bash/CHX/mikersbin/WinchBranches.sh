#!/bin/bash
repos=(Winchester_MS Services/AdaptiveServiceCore Services/WebClient Services/VFDService Services/HistoryService Services/ConfigurationService Services/ModbusService Services/RodLiftService Services/IOBrokerService)
branches=(QA main dev master)
BASE="${PWD%/*}"
OUTPUT="Branches.csv"
TOPBR=${repos[0]}
CURDIR=${PWD##*/}

if [[ $TOPBR != $CURDIR ]] ;then
	cd ${TOPBR}
fi

[ -e  ${BASE}/${OUTPUT} ] && rm ${BASE}/${OUTPUT}

for r in ${repos[*]}
{
	echo -e ${r##*/}",\c" >>${BASE}/${OUTPUT}
}
echo >> ${BASE}/${OUTPUT}
((maxidx=${#branches[*]}-1))
((maxridx=${#repos[*]}-1))
#echo "== max branch $maxidx ==="
for i in $(seq 0 ${maxidx})
{
	for r in $(seq 0 ${maxridx})
	{
		#echo "========= ${repos[$r]} ============"
		if [[ $r -gt 0 ]] ; then
			cd ${repos[$r]}
		fi
		#echo "========== $i branch ${branches[$i]} =========="
		brch=$(git branch -r |grep '\/'${branches[$i]}'$' |grep -v HEAD |sed -e 's!origin/!!' -e 's![[:space:]]!!g')
		echo -n "${brch}," >> ${BASE}/${OUTPUT}
		if [[ $r -gt 0 ]] ; then
			cd - > /dev/null
		fi
	}
	echo >> ${BASE}/${OUTPUT}
}
ls -l ${BASE}/${OUTPUT}
cat ${BASE}/${OUTPUT}
