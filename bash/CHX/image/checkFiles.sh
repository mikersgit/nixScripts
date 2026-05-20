#!/bin/bash
OtherDir=${1}
mfiles=($(cat mfiles))

for f in ${mfiles[*]}
{
   a=$(md5sum $f|cut -d" " -f1,1)
   b=$(md5sum ${OtherDir}/$f|cut -d" " -f1,1)
   if [[ ! $a =~ $b ]];then
	echo  $a $f
	echo  $b ${OtherDir}/$f
   fi
}
