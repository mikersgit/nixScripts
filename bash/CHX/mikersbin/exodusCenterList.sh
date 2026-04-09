#!/bin/bash
# list the files images on exodus.center
#
ECENTERurl=http://exodus.center/files/
if [ $# -lt 1 ]
then
	echo "USAGE: ${0##*/} <web dir> <file suffix>"
	echo "eg: ${0##*/} genesis xz"
	dirs=(sd_card iotbone genesis sd_card/release genesis/V5.1.0%20pre-release genesis/v5.0.0_pre-release)
	sfxs=(xz img mbn)
	echo "URL: ${ECENTERurl}"
	echo "Web Dirs: ${dirs[@]}"
	echo "Suffixes: ${sfxs[@]}"
	exit
fi

DIR=${1}
SFX=${2}
wget -O - -q -np -nd -nH ${ECENTERurl}${DIR} |
sed -e 's/</ /g' -e 's/>/ /g' |
awk -v SFX=${SFX} '{if ( $3 ~ ".*"SFX"$" ) print $3" "$5" "$6}'


