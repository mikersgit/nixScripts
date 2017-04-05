#!/bin/bash
tip=10.30.252.45
tmod='47_fs1'
debug="-vv \
      --log-format=\"%t,<%p>,%i,%n%L\" \
      --stats \
      --itemize-changes "

#--delete-during \
#--recursive \
#-WRlptgoDdAX \
#-WaAX \

rsrc='/43_fs1'
rdsrc='/one/two/'
rtgt='/bkup/Monday'
rsync   --port=9559 \
${debug} \
--hard-links \
-WaAX \
--no-recursive \
--dirs \
--modify-window=1 \
--bwlimit=0 \
--inplace \
${rsrc}/one ${tip}::${tmod}/one #NB. NO trailing slash

rsync   --port=9559 \
${debug} \
--hard-links \
-WaAX \
--modify-window=1 \
--bwlimit=0 \
--inplace \
${rsrc}${rdsrc} ${tip}::${tmod}${rdsrc}

exit 0
#/usr/local/ibrix/bin/ibrcfrworker --port=9202 --hard-links -WaAX --log-format="%t,<%p>,%i,%n%L" --stats --itemize-changes --modify-window=1 --bwlimit=0   --inplace --exclude-from=/var/log/cfr/ibrcfrworker.exclude.43_fs1 /mnt/ibrix/filter/tasks/2/43_fs1/one/two/ 10.30.252.46::47_fs1_bkup/one/two/

