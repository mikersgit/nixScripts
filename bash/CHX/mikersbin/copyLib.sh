#!/bin/bash
SrcDir=$1
DestDir=$2
Ver="-"$3
LibDir=Clibs/libRIB2
SrcTar="${HOME}/tarfiles/ExodusCapps.tar.xz"
LIB=libRIB2.so.1.0
WWWserv=exodus@50.116.29.158
WWWpath=/usr/local/www/files/misc/${DestDir}
prog=${0##*/}
GDBscripts=(~/bin/gdbSetup.sh ~/bin/gdbSrcInstall.sh)

if [ x$4 != x ]
then
   export GDB=1
else
   unset GDB
fi

if [ $# -lt 3 ]
then
	echo "USAGE: ${prog} <srcdir> <destdir> <version> [GDB]"
	echo "   eg. ${prog} ExodusPaul paul V45"
	exit 1
fi

cd ${HOME}/${SrcDir}/${LibDir}

if [ -e $LIB ]
then
	echo -e "Copy ${HOME}/${SrcDir}/${LibDir}/${LIB} to\n\texodus.center/files/misc/${DestDir}/${LIB}${Ver}"
	rsync -v -e 'ssh -p 2730' ${LIB} ${WWWserv}:${WWWpath}/${LIB}${Ver}
else
	echo "ERROR: ${SrcDir}/${LIB} not found."
	exit 1
fi

if [ x${GDB} != x ]
then
	if [ -e ${SrcTar} ]
	then
		echo "Copy Source tar file"
		rsync -v -e 'ssh -p 2730' ${SrcTar} ${WWWserv}:${WWWpath}/${SrcTar##*/}${Ver}
		rsync -e 'ssh -p 2730' ${GDBscripts[@]} ${WWWserv}:${WWWpath}/.
	else
		echo "ERROR: ${SrcTar} not found."
		exit 1
	fi
fi
