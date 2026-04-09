#!/bin/bash
dbgDir=/home/exodus/GenesisMcp
echo "in $PWD"
ls | while read FILE
do
	#ls ${dbgDir}/${FILE} 
	if [[ -e ${dbgDir}/${FILE} ]]
	then
		#echo "${FILE} exists in both"
		:
	else
		echo "${FILE} only in Engine"
		cp -R ${FILE} ${dbgDir}/${FILE} 
	fi
done
