#!/bin/bash
gfl='libRIB2.so.1.0'
base='exodus'
if [[ $# = 1 ]]
then
   gfl="${1}"
elif [[ $# = 2 ]]
then
   base="${1}"
   gfl="${2}"
fi
# exodus@geneng.oilgas.center
cdev=199.180.249.167
libdir=${base}/Clibs/libRIB2
key='/cygdrive/c/users/20801921/OneDrive - ChampionX/Documents/access/mwr_rsa'
file=${libdir}/${gfl}
scp -i "${key}" -P 2730 exodus@${cdev}:${file} .
md5sum.exe ${gfl}
