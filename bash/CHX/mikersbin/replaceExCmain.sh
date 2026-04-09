#!/bin/bash

########################
# ChampionX 2022
# Replaces the app and lib for ExodusCmain in copy of the debian image in /build/rootfs-....
# use getExCmain.sh to populate excmain
########################

targetDir=${1}
excmainDir=${2}

if [ $# -lt 2 ]
then
   echo "USAGE: ${0} <target dir> <excmainDir>"
   echo "EG.    ${0}  /build/rootfs-20220526 excmain/"
   echo "Use getExCmain.sh to populate excmain"
   exit 1
fi

echo "Copying ExodusCmain app and lib ${excmainDir} to ${targetDir}"
./syncDirs.sh ${excmainDir}/ ${targetDir}/home/exodus/
