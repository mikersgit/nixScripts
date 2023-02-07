#!/bin/bash

########################
# ChampionX 2022
# Replaces the smarten firmware in copy of the sdcard image in /build/rootfs-....
# It is left to the user to then copy this into the mounted sdcard image.
########################

targetDir=${1}
tarFile=${2}

if [ $# -lt 2 ]
then
   echo "USAGE: ${0} <target dir> <smarten tar file>"
   echo "EG.    ${0}  /build/rootfs-20220526 smarten-5.0.0.33.4251.tar.xz"
   exit 1
fi

# extract smarten tar to /build
echo "Extracting tar ${tarFile} to ${targetDir}"
tar -C ${targetDir} --exclude=.bash_history -xpvf ${tarFile}

#compare build with mounted image
# remove 'n' options to actually move files
#####
echo "comparing with rsync: ${targetDir}/ /mnt/img/"
rsync --exclude=.bash_history --exclude="genesis*sqlite" -xrplcvn ${targetDir}/ /mnt/img/
read -p "Copy to sdcard image? [N]|Y " ans
if [ x${ans} = "xY" ]
then
	echo "Rsync ${targetDir}/ to /mnt/img/"
	rsync --exclude=.bash_history --exclude="genesis*sqlite" -xrplcv ${targetDir}/ /mnt/img/
fi
