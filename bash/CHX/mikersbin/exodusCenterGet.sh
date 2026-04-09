#!/bin/bash
# list the files images on exodus.center
#

ECENTERurl=http://exodus.center/files/

if [ $# -lt 2 ]
then
	echo "USAGE: ${0##*/} <web dir> <file>"
	echo "eg: ${0##*/} genesis smarten-5.0.0.41.4667.tar.xz"
	dirs=(sd_card iotbone genesis sd_card/release genesis/V5.1.0%20pre-release genesis/v5.0.0_pre-release)
	echo "URL: ${ECENTERurl}"
	echo "Web Dirs: ${dirs[@]}"
	exit
fi

DIR=${1}
FILE=${2}

echo "Retrieving  ${ECENTERurl}${DIR}/${FILE}"
wget -qr -np -nd -nH -A ${FILE} ${ECENTERurl}${DIR}/ &
pid=$!
while :
do
	sleep 5
	JPID=$(jobs -pr)
	if [ x${pid} = x${JPID} ]; then
		tput el;tput sc;printf %s"	"%s $(ls -l ${FILE}| awk '{print $5" "$9}') ;tput rc
	else
		tput el;tput sc;printf %s"	"%s $(ls -l ${FILE}| awk '{print $5" "$9}') ;tput rc
		echo
		echo "Completed"
		break
	fi
done
