#!/bin/bash
mpth=$1
rpth=/mnt/c/Users/20801921/source/repos/rootfs/current
cd $mpth
pwd
usage(){
	echo "${0##*/} <mnt point> <action>"
	echo "Actions:"
	echo "l for list of differences"
	echo "c to copy from mount to git"
	echo "example: ${0##*/} /mnt/sdcard l"
	echo "to list differences from /mnt/sdcard to $rpth"
	echo "Need to be root or sudo"
	exit 1
}
case $2 in
	[lL]) list=1;copy=0 ;;
	[cC]) copy=1;list=0;;
	*) usage ;;
esac

who=$(id -u)
if [ $who -gt 0 ] ;then
	echo "==== NOT ROOT ===="
	usage
fi

for f in $(find . -type f ! -path \*home/exodus\*|sed 's!^./!!')
{
	if [ -e $f ] && [ -e ${rpth}/${f} ]
       	then
		a=$(md5sum $f|awk '{print $1}')
		b=$(md5sum ${rpth}/$f|awk '{print $1}')
		if [ $a = $b ]
		then
			#echo 'same'
			:
			#echo "mnt: $a root: $b"
		else
			if [ $list -eq 1 ] ; then
				echo $f
				echo "copy from: $mpth/$f to: $rpth/$f"
				cp $f $rpth/$f
			else
				ls -l $f $rpth/$f
			fi
			#sdiff -w 160 -s $f $rpth/$f
		fi
	fi
}
