#!/bin/bash
# list the sdcard images on exodus.center
#
SDCARDurl=http://exodus.center/files/sd_card 
echo "Retrieving  ${SDCARDurl}/${1}"
wget -qr -np -nd -nH -A ${1} ${SDCARDurl} &
pid=$!
while :
do
	sleep 5
	JPID=$(jobs -pr)
	if [ x${pid} = x${JPID} ]; then
		tput el;tput sc;printf %s"	"%s" "%d" "%d $(ls -l ${1}| awk '{print $5" "$9}') ${pid} ${JPID};tput rc
	else
		echo
		echo "Completed"
		break
		exit
	fi
done
