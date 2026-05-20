#!/bin/bash
SRC=/mnt/c/cygwin64/home/20801921/src
for f in *sh
{
	a=$(md5sum $f|cut -d " " -f1,1)
	if test -e $SRC/$f
	then
		b=$(md5sum $SRC/$f|cut -d " " -f 1,1)
		if [[ $a = $b ]]
		then
			#echo "same"
			:
		else
			echo "$f not the same"
		fi
	else
		echo " $SRC/$f does not exist"
		b=$a
	fi
}
