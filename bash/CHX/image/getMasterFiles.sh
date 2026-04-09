#!/bin/bash
# output of 'git diff --name-only master'
DIFFfiles=$1
for f in $(< ${DIFFfiles})
{
	Dfile=${f##*/}
	DOUTfile=${Dfile}".master"
	Ddir=${f%/*}
	if [[ ${Ddir} = ${Dfile} ]]
	then
		Ddir="."
	fi
	echo "Ddir: ${Ddir} Dfile: ${Dfile}"
	
	if [[ -e ${Ddir}/${Dfile} ]]
	then
		git show master:${Ddir}/${Dfile} > ${Ddir}/${DOUTfile}
	else
		DOUTfile=${Dfile}".ADD"
		git show master:${Ddir}/${Dfile} > ${Ddir}/${DOUTfile}
	fi
	if [[ ! -s ${Ddir}/${DOUTfile} ]]
	then
		mv ${Ddir}/${DOUTfile} ${Ddir}/${Dfile}".DELETE"
		DOUTfile=${Dfile}".DELETE"
		
	fi
	ls ${Ddir}/${Dfile} ${Ddir}/${DOUTfile}
}
