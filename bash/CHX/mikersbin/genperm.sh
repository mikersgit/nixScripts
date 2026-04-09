#!/bin/bash

MNTDIR=$(echo ${1}| sed 's/home\/exodus//')
BASEDIR=$1
GENDIR=${BASEDIR:-"/home/exodus"}
PRJ0=app
PRJ1=Engine
PRJ2=GenesisMcpClient
PRJ3=SmartenServer
PRJ4=SmartenClient
PRJ5=Databases

#
# determine if the user is root
#
if [ $(id -u) -gt 0 ]
then
  SUDO=/usr/bin/sudo
else
  #Already root
  SUDO=""
fi

if [ ${#} -eq 0 ]
then
   echo "No argument given. If you want to opperate on ${GENDIR}"
   echo "then provide '/' on the commandline"
   exit 1
fi

#
# verify that the starting directory makes sense
#
if echo ${GENDIR} | grep -v "exodus"
then
   echo "exodus not in the path you provided."
   echo "try something like ${0} /mnt/img/home/exodus"
   exit 1
fi

${SUDO} chown -R exodus:users $GENDIR

cd $GENDIR
echo -e "Working in:\n$PWD"
TAG=${PWD%/home*}/etc/dogtag

${SUDO} chmod -R 775 $PRJ0 &

for DIR in $PRJ1 $PRJ2 $PRJ3 $PRJ4 $PRJ5; do
   if [ -d ${DIR} ] ;then
	${SUDO} find $DIR -type f -exec chmod 664 {} \; &
	${SUDO} find $DIR -type d -exec chmod 775 {} \; &
   fi
done

wait

# Update dogtag:
ans="N"
echo "Only update the Dogtag file if changes were made to the operating system."
read -p "Update Dogtag file? [N]|Y " ans

if [ "x"${ans} = "xY" ]
then
	echo ChampionX Debian 9 Image `TZ=America/Chicago date +%Y-%m-%d\ %Z\ %H:%M` > $TAG
	echo ${TAG}
fi
cat $TAG

date the Dogtag file if changes were made to the operating system."
read -p "Update Dogtag file? [N]|Y " ans

if [ "x"${ans} = "xY" ]
then
	echo ChampionX Debian 9 Image `TZ=America/Chicago date +%Y-%m-%d\ %Z\ %H:%M` > $TAG
	echo ${TAG}
fi
cat $TAG

