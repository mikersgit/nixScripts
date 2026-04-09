#!/bin/bash

#######################
# ChampionX 2022
# create SystemUpdate tar file from mounted sdcard image.
#######################
tarDest="../../build/SystemUpdate.tar"
cd /mnt/img
time tar -cpvf ${tarDest}  *
] ; then
	i=$( ls -1 sd*[xz,img] |grep -v fresh|head -1)

	echo "${0##*/} <sdcard image> <mount point>"
	echo "${0##*/} ${i} /mnt/sdcard"
	exit 1
fi
${BLDTOOL} -i $img -b $mnt -m

img=$(echo $img | sed 's/.xz$//')
ver=$(echo $img | sed -e 's/sdcard-//' -e 's/.img//')
tarDest="/build/SystemUpdate-${ver}.tar"
cd ${mnt}
echo -e "\n\t============ Creating $tarDest from $mnt ============"
time tar -cpf ${tarDest}  * &
tarpid=$!
renice --priority -10 $(pgrep tar)
wait ${tarpid}
cd ${TOOLDIR}
${BLDTOOL} -i $img -b $mnt -u
