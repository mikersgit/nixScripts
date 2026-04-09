#!/bin/bash
if [[ ${#} -lt 1 ]] ; then
	echo "Available arguments:"
	echo SCREENSAVER_BRIGHTNESS=30
	echo SCREENSAVER=OFF
	echo SCREENSAVER_TIMEOUT=600
	exit 1
fi
HMI=/home/exodus/hmi.sh
TMPHMI=$(mktemp)
# example ${0} "SCREENSAVER_TIMEOUT=600"
SCREENARG=${1}
# Remove any previous SCREENSAVER overrides
sed -i '/SCREENSAVER/d' $HMI
awk -v SCREENARG="${SCREENARG}" '{if ( $1 ~ "^PROG" ) {printf "export %s\n%s\n", SCREENARG, $0} else print $0}' ${HMI} > ${TMPHMI} 
mv ${TMPHMI} ${HMI}
chmod +rx ${HMI}
sudo monit restart hmi
