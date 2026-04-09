#!/bin/bash
DIFFfile=${1}
BASE1=${2}
BASE2=${3}
if [ $# -lt 3 ]
then
	echo "USAGE: ${0##*/} <file with diffs> <mount dir> <git dir>"
	echo "  eg.  ${0##*/} deltas.txt /mnt/timg rootfs/current/"
	exit 1
fi

#for f in $(< ${DIFFfile})
cat ${DIFFfile} |  sort -u | while read s f
do 
	case $s in
	D)
   		echo "DELETE: $f"
		;;
	*)
		#fDIR=${f%/*}
		#fFILE=${f##*/}
		echo "========== $f =========="
   		ls -l ${BASE1}/${f} ${BASE2}/${f}
   		md5sum ${BASE1}/${f} ${BASE2}/${f}
		;;
	esac
done
