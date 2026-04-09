#!/bin/bash

########################
# ChampionX 2022
# Replaces the smarten firmware in copy of the debian image in /build/rootfs-....
# It is left to the user to then copy this into the mounted debian image.
########################

targetDir=${1}
tarFile=${2}
mnt=${3}

if [ $# -lt 3 ]
then
   echo "USAGE: ${0} <target dir> <smarten tar file> <img mnt dir>"
   echo "EG.    ${0}  /build/rootfs-20220526 smarten-5.0.0.33.4251.tar.xz /mnt/timg"
   exit 1
fi

function genperm() {

	BASEDIR="${targetDir}/home/exodus"
	MNTDIR=$(echo ${BASEDIR}| sed 's/home\/exodus//')
	GENDIR=${BASEDIR:-"/home/exodus"}
	PRJ0=app
	PRJ1=Engine
	PRJ2=GenesisMcpClient
	PRJ3=SmartenServer
	PRJ4=SmartenClient
	PRJ5=Databases
	TAG=${MNTDIR}/etc/dogtag

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
	echo Working in:\\n$PWD

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

} #end genperm()

# extract smarten tar to /build
echo "Extracting tar ${tarFile} to ${targetDir}"
tar -C ${targetDir} --exclude=.bash_history -xpvf ${tarFile}

genperm
#compare build with mounted image
# remove 'n' options to actually move files
#####
read -p "Compare ${targetDir}/ ${mnt}/ to debian image? [N]|Y " ans
if [ x${ans} = "xY" ]
then
	echo "comparing with rsync: ${targetDir}/ ${mnt}/"
	rsync --exclude=.bash_history --exclude="genesis*sqlite" -xrplcvn ${targetDir}/ ${mnt}/
fi
read -p "Copy to debian image? [N]|Y " ans
if [ x${ans} = "xY" ]
then
	echo "Rsync ${targetDir}/ to ${mnt}/"
	rsync --exclude=.bash_history --exclude="genesis*sqlite" -xrplcv ${targetDir}/ ${mnt}/
fi
"${GENDIR}" ]; then
		echo "Warning: Directory ${GENDIR} does not exist. Skipping permission setup."
		return 0
	fi

	${SUDO} chown -R ${EXuser}:users $GENDIR

	cd $GENDIR
	echo -e "Working in:\n$PWD"

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
		# Ensure the etc directory exists for dogtag
		mkdir -p "$(dirname ${TAG})"
		echo ChampionX Debian 9 Image `TZ=America/Chicago date +%Y-%m-%d\ %Z\ %H:%M` > $TAG
		echo ${TAG}
	fi
	
	# Only display dogtag if it exists
	if [ -f "$TAG" ]; then
		cat $TAG
	else
		echo "No dogtag file found at: $TAG"
	fi

} #end genperm()

# extract smarten tar to the appropriate path
echo "Extracting tar ${tarFile} to ${extractionPath}"
tar -C ${extractionPath} --exclude=.bash_history -xpvf ${tarFile}

# Check if extraction was successful
if [ $? -eq 0 ]; then
    echo "Extraction completed successfully"
else
    echo "Error: Extraction failed"
    exit 1
fi

genperm

# For comparison and copying, use the extraction path
comparisonPath=${extractionPath}
if [[ ${targetDir} == *"userdata"* ]]; then
    echo "Note: Using vault subdirectory for userdata operations"
fi

#compare build with mounted image
# remove 'n' options to actually move files
#####
read -p "Compare ${comparisonPath}/ ${mnt}/ to debian image? [N]|Y " ans
if [ x${ans} = "xY" ]
then
	echo "comparing with rsync: ${comparisonPath}/ ${mnt}/"
	rsync --exclude=.bash_history --exclude="genesis*sqlite" -xrplcvn ${comparisonPath}/ ${mnt}/
fi
read -p "Copy to debian image? [N]|Y " ans
if [ x${ans} = "xY" ]
then
	echo "Rsync ${comparisonPath}/ to ${mnt}/"
	rsync --exclude=.bash_history --exclude="genesis*sqlite" -xrplcv ${comparisonPath}/ ${mnt}/
fi
