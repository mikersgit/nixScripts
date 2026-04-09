#!/bin/bash
SUFFIX=$1
TARGIP=$2
EXCM=ExodusCmain.exe
LIBR=libRIB2.so.1.0
WEBPATH=https://exodus.center/files/misc/paul
EXUSER=exodus
WHOTO=${EXUSER}@${TARGIP}
HOMEDIR=/home/exodus
DWNLDS=${HOMEDIR}/downloads
REPLCMD=libReplace.sh
#######
# pull from exodus.center
#######
for i in $EXCM $LIBR
{
	target=${i}-${SUFFIX}
	wget ${WEBPATH}/${target}
	md5sum ${target}
	ls -l ${target}
}


#######
# push to test unit
#######
for i in $EXCM $LIBR
{
	target=${i}-${SUFFIX}
	scp -P 2730 ${target} ${WHOTO}:${DWNLDS}/.
}
ssh -p 2730 ${WHOTO} ${HOMEDIR}/${REPLCMD} ${SUFFIX}
