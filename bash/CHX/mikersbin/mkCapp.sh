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
cd ~/${base}/
echo '=========='
pwd
git branch
git status
echo '=========='

echo =================================
echo Entering Clibs/libSQlite
echo =================================
cd Clibs/libSQlite
make clean
make libSQlite.a

echo =================================
echo Entering ../libJSON
echo =================================
cd ../libJSON
make clean
make libJSON.a

echo =================================
echo Entering ../libFreeRTOS
echo =================================
cd ../libFreeRTOS
make clean
make libFreeRTOS.a

echo =================================
echo Entering  ../libRIB2
echo =================================
cd ../libRIB2
make clean
make libRIB2.a

echo =================================
echo Entering  ../../Capps/CappManager
echo =================================
cd ../../Capps/CappManager
make clean
make ExodusCmain.exe settime.exe

echo =================================
echo Entering  ../RIB2hardwareControl
echo =================================
cd ../RIB2hardwareControl
make clean
make RIB2hardwareControl.exe

echo =================================
echo Entering  ../SchneiderKeepAlive
echo =================================
cd ../SchneiderKeepAlive
make clean
make SchneiderKeepAlive.exe

cd ${HOME}
tar -vcf ~/AppPkg.tar $(find app -type f -ctime -1)
tar -vcf ~/LibPkg.tar $(find lib -type f -ctime -1)
