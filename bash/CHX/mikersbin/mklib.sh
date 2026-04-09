#!/bin/bash
base='exodus'
if [[ $# > 0 ]]
then
   base=${1}
fi
if [ x$2 != x ]
then
   export GDB=1
else
   unset GDB
fi
export PATH=/home/exodus/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
export CROSS_COMPILE=/build/gcc/bin/arm-linux-gnueabihf-
echo $CROSS_COMPILE
cd ~/${base}/Clibs/libRIB2
echo '=========='
pwd
git branch
git status
echo '=========='
make clean
make
md5sum libRIB2.so.1.0
