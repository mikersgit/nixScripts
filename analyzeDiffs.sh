#!/bin/bash
 sd=/build/sdcard-2025219
 rc=/build/image/rootfs/current
 for f in $(grep "same" compareSDtoGIT.txt|grep -v fb$ |awk '{print $1}'|grep -v fb$)
 do
 echo "========= $f =========="
 sdiff -w 200 -s $sd/$f $rc/$f
 read -p "Keep: " ans
echo $ans
 if [ ${#ans} -gt 0 ] && [ ${ans} = "y" ] ; then
	 echo $f >> keepDiff.txt
 fi
 done
