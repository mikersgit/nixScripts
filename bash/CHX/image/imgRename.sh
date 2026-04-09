#!/bin/bash
if [ $# -lt 2 ]
then
	echo "$0 sdcard-20230719-5.1.0.212.img smarten-5.1.0.208.4724.tar.xz"
	exit
fi
sep="-"
dt=$(date "+%Y%j")
nver=$(echo $2 | awk '{sub("smarten-","");sub(".tar.xz","");gsub("\."," ");print $1"."$2"."$3"."$4}')
echo $1 | awk '{gsub("-"," "); sub(".img"," img");print}' |while read typ sys ver sfx
do
	echo "typ="${typ} "sys="${sys} "ver="${ver} "sfx="${sfx}	
	nfile=${typ}${sep}${dt}${sep}${nver}".img"
	echo "rename ${1} to ${nfile}"
	mv  ${1} ${nfile}
	ls -l  ${nfile}
	break
done

