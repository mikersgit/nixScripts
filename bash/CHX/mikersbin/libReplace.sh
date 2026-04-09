#!/bin/bash
SUFFIX=$1
EXCM=ExodusCmain.exe
LIBR=libRIB2.so.1.0
WEBPATH=https://exodus.center/files/misc/paul
sudo monit summary
cd /home/exodus/downloads
for i in $EXCM $LIBR
{
	target=${i}-${SUFFIX}
	wget ${WEBPATH}/${target}
	md5sum ${target}
	ls -l ${target}
}
mv ${LIBR}-${SUFFIX} /home/exodus/lib
mv ${EXCM}-${SUFFIX} /home/exodus/app

cd /home/exodus/lib
mv ${LIBR} ${LIBR}-$(date '+%y%m%b%h%m') 
ln ${LIBR}-${SUFFIX} ${LIBR}
chmod +x ${LIBR}
ls -l libRIB2*
md5sum ${LIBR}

cd /home/exodus/app
mv ${EXCM} ${EXCM}-$(date '+%y%m%b%h%m') 
ln ${EXCM}-${SUFFIX} ${EXCM}
chmod +x ${EXCM}
ls -l ExodusCmain*
md5sum ${EXCM}




