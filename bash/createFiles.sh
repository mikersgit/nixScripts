#!/bin/bash

NumDirs=0

while getopts :f:d:s:?h OPT; do
    case $OPT in
	f|+f)
	NumFiles="$OPTARG"
	;;d|+d)
	NumDirs="$OPTARG"
	;;s|+s)
	SizFiles="$OPTARG"
	;;*)
	echo "usage: ${0##*/} [-f num files] [-d num dirs] [-s KB size] [+-?h]"
	exit 2
    esac
done

NamFiles="${SizFiles}KB"

if (( ! NumDirs ))
then
    if (( NumFiles < 100 ))
    then
        NumDirs=1
    else
        #(( NumDirs = 10 * ( NumFiles / 100 ) ))
        (( NumDirs = ( NumFiles / 100 ) ))
    fi
fi

(( NumFilesPdir = NumFiles/NumDirs ))

#assume starting in PWD

top=${PWD}

cd ${top}
if [[ ! -f ~/${NamFiles} ]]
then
        # using dd create non-sparse files of random characters
        ~/bin/ddOptions.sh -t full -N ~/${NamFiles} -z ${NamFiles} -c random
fi

for ((d=0;d<${NumDirs};d++))
{
	[[ ! -d ${d} ]] && mkdir $d
	cd $d
	{
	for ((k=0;k<${NumFilesPdir};k++))
	{
		cp ~/${NamFiles} ${NamFiles}_${k}
	}
	} &
	cd ${top}
}
