#!/bin/bash

# create 14 directories each with 100x4M files 10x40M 1x400M
# so that is 1.2G in each dir
top=${1}
: ${top:='/fs_10Segs'}
cd ${top}
if [[ ! -f ~/400MB ]]
then
        # using dd create non-sparse files of random characters
        ~/bin/ddOptions.sh -t full -N ~/400MB -z 400MB -c random
        ~/bin/ddOptions.sh -t full -N ~/40MB -z 40MB -c random
        ~/bin/ddOptions.sh -t full -N ~/4MB -z 4MB -c random
fi

for ((d=0;d<14;d++))
{
	[[ ! -d ${d} ]] && mkdir $d
	cd $d
	{
	for ((k=0;k<1;k++))
	{
	#	cp ~/400MB 400MB_${k}
		cp ~/40MB 40MB_${k}
		cp ~/4MB 4MB_${k}
	}
	} &
	{
	for ((k=1;k<10;k++))
	{
		cp ~/40MB 40MB_${k}
		cp ~/4MB 4MB_${k}
	}
	} &
	{
	for ((k=10;k<100;k++))
	{
		cp ~/4MB 4MB_${k}
	}
	} &
	cd ${top}
}
