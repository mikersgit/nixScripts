#!/bin/bash

########################
# ChampionX 2025
# Replaces the smarten firmware in copy of the debian image in /build/rootfs-....
# It is left to the user to then copy this into the mounted debian image.
# 
# MODIFICATION: Handle special case where target directory contains "userdata"
# - If target dir contains "userdata", append "/vault" to the extraction path
########################

targetDir=${1}
tarFile=${2}
mnt=${3}

if [ $# -lt 3 ]
then
   echo "USAGE: ${0} <target dir> <smarten tar file> <img mnt dir>"
   echo "EG.    ${0}  /build/rootfs-20220526 smarten-5.0.0.33.4251.tar.xz /mnt/timg"
   echo "EG.    ${0}  /build/userdata-20220526 smarten-5.0.0.33.4251.tar.xz /mnt/timg"
   echo "       (userdata case will extract to /build/userdata-20220526/vault)"
   exit 1
fi

# Check if target directory contains "userdata" and modify extraction path
extractionPath=${targetDir}
if [[ ${targetDir} == *"userdata"* ]]; then
    extractionPath="${targetDir}/vault"
    echo "Target directory contains 'userdata' - extracting to: ${extractionPath}"
    # Create the vault directory if it doesn't exist
    mkdir -p "${extractionPath}"
else
    echo "Standard extraction to: ${extractionPath}"
fi

function genperm() {
	EXuser=exodus
	# Use the extraction path for setting up the base directory
	if [[ ${targetDir} == *"userdata"* ]]; then
		BASEDIR="${extractionPath}/home/${EXuser}"
	else
		BASEDIR="${targetDir}/home/${EXuser}"
	fi
	
	MNTDIR=$(echo ${BASEDIR}| sed 's/home\/${EXuser}//')
	GENDIR=${BASEDIR:-"/home/${EXuser}"}
	PRJ0=app
	PRJ1=Engine
	PRJ2=GenesisMcpClient
	PRJ3=SmartenServer
	PRJ4=SmartenClient
	PRJ5=Databases
	TAG=${MNTDIR}/etc/dogtag

	echo "Setting permissions for directory: ${GENDIR}"

	# make sure exodus user exists
	ret=$(id ${EXuser} &>/dev/null ; echo $?)
	if [ $ret -gt 0 ];then
		echo "${EXuser} user does not exist, try useradd command to fix"
		echo "useradd -u 1001 -g 100 -o ${EXuser}"
		exit 1
	fi
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
	if echo ${GENDIR} | grep -v "${EXuser}"
	then
   		echo "${EXuser} not in the path you provided."
   		echo "try something like ${0} /mnt/img/home/${EXuser}"
   		exit 1
	fi

	# Check if the directory exists before trying to change ownership
	if [ ! -d "${GENDIR}" ]; then
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
