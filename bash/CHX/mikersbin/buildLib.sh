#!/bin/bash
if [ x$3 != x ]
then
   export GDB=1
else
   unset GDB
fi
base=$1
Branch=$2
prog=${0##*/}
SrcTar="${HOME}/tarfiles/ExodusCapps.tar"

if [ $# -lt 2 ]
then
	echo "USAGE: ${prog} <srcdir> <git branch> [GDB]"
	echo "   eg. ${prog} ExodusPaul issue5088"
	exit 1
fi
export PATH=/home/exodus/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
export CROSS_COMPILE=/build/gcc/bin/arm-linux-gnueabihf-
echo $CROSS_COMPILE
cd ~/${base}/Clibs/libRIB2
echo '=========='
pwd
# git pull so we have references to latest branches
git pull
# get the requested branch, and switch to it 
git checkout ${Branch}
# pull any changes to the branch
git pull
# display the current branch
git branch
# display any extraneous files, or modified files
git status
echo '=========='
make clean
make
# describe the built binary
md5sum libRIB2.so.1.0
strings libRIB2.so.1.0 |grep V5

if [ x${GDB} != x ]
then
	echo "Compilation Path: ${HOME}/${base}"
	echo "Creating Source tar file"
	cd ~/${base}
	tar -cf ${SrcTar} Capps Clibs
	echo "Compressing Source tar file (takes upto 60 seconds)"
	[ -e "${SrcTar}.xz" ] && rm "${SrcTar}.xz"
	xz ${SrcTar}
fi
