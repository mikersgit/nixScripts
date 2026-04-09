#!/bin/bash

############################
# ChampionX 2022
# open up an existing sdcard install image to allow changes to the operating system and/or the Smarten firmware image.
# The methodology is to copy the contents of the OS and firmware to /build/rootfs-<version>, make changes there, then copy
# the contents of the /build/rootfs-<version> back to the mounted image.
############################


# date +"%Y%m%d%H%M"
pVersion=202305221631

dstr='+%H:%M:%S'
cardimg=${1}
delim='========='
prog=${0}
mntdir=/mnt/img
bldDir=/build
WSL=0
if [ -e /mnt/c ]; then
	WSL=1
	echo "On Windows WSL"
fi

function usage() {
   echo "USAGE: ${prog} -i sdcard-YYYYMMDD.img[.xz] -b /mnt/img [-m|u|d|F]"
   echo "   -i <img> the sdcard, rootfs, or userdata disk image file"
   echo "   -b <MntPoint> the directory to mount the disk image."
   echo "       Without m/u/d options, the image is mounted, and a copy is made to /build/rootfs-..."
   echo "   -m  Only mount the image, do not copy."
   echo "   -u  Fill empty space in image with zeros to improve compression, then Unmount the image."
   echo "   -d  Diff the image and the corresponding /build/rootfs-..."
   echo "   -F  Update the home directory permissions and dogtag. Can be used with -u option"
   echo "VERSION=${pVersion}"
   exit 1
}

#
# verify the user is root
#
function checkUser() {
    if (( $(id -u) > 0 ))
    then
      echo -e "\t${delim}\nHey $USER, must be root to run ${0}\n\t${delim}"
      exit 1
    fi
} # end checkUser()

##########
# display the current time every 5 seconds, using tput to overwrite the
# previous displayed time
# it is expected that this function will be called into the background (&)
# and then killed when the command being called completes
##########
function timer() {
	while :
	do
	    tput sc;printf %s $(date ${dstr});tput rc
	    sleep 5
	done
} # end timer()

function setupBldPath() {
    imgName=$(echo ${cardimg}| cut -d "-" -f 1)
    idstr=$(echo ${cardimg}| cut -d "-" -f 2 |cut -d "." -f1)
    bldPath=${bldDir}/${imgName}-${idstr}
    if [ ! -d ${bldPath} ]
    then
    	mkdir -p ${bldPath}
    fi
} # end setupBldPath()

##########
function setupDirs() {
    mkdir -p ${mntdir}
    mkdir -p ${bldDir}
    setupBldPath
} # end setupDirs()

#
# determine if the image is compressed
#
function checkImg() {
    if [[ ${cardimg} == *xz ]]
    then
       echo "Decompressing ${cardimg}, this takes about 5 minutes"
       date
       timer & 
       pid=$!
       time xz -d ${cardimg}
       kill ${pid}
       date
       # remove the xz suffix
       cardimg=${cardimg%.xz}
    fi
} # end checkImg()

function imageMount() {
    function listMnts(){
      mount -t ext4 |grep img
    }
    img=$1
    mnt=$2
    if [ ${WSL} -eq 1 ];then
	    mntOpts='-v -o loop -t ext4'
    else
	    mntOpts=''
    fi
    if file ${img} | grep -q ext4
    then
    	echo "tbone"
    	mount ${mntOpts} ${img} ${mnt}
    elif file ${img} |grep -q MBR
    then
	echo "bbb"
	mount ${mntOpts} -o offset=1048576 ${img} ${mnt}
    else
       echo -e "\n=========== no mount type found for ${img} ===========\n"
    fi

    df -h
}

function doMount() {
    checkImg
    setupDirs
    #mount -o offset=1048576 ${cardimg} ${mntdir}
    imageMount ${cardimg} ${mntdir}
    df ${mntdir}
} # end doMount()

function zeroOut() {
    # writing zeros to the mount point empty space makes the
    # image compress better
    echo "zero-ing out free space on mounted image ${1}"
    outfile=${1}/zero
    dd bs=8K if=/dev/zero of=${outfile} 2>/dev/null
    sync ${1}
    rm ${outfile}
} # end zeroOut()

function finalizeImage () {
	HmDir=${mntdir}/home/exodus
	if [ ! -x /home/exodus/tmp/genperm.sh ] ;then
		echo "/home/exodus/tmp/genperm.sh not found, exiting"
		exit 1
	fi
	/home/exodus/tmp/genperm.sh ${HmDir}
}

function doUmount() {
    zeroOut ${mntdir}
    umount ${mntdir}
    df
} # end doUmount

##########
function copyImage() {
    echo "Copying mounted install image to ${bldPath}, this can take up to 10 minutes."
    date
    timer &
    pid=$!
    #time cp -a ${mntdir}/* ${bldPath} &
    time rsync --exclude=.bash_history --exclude="genesis*sqlite" -arlc ${mntdir}/* ${bldPath} &
    cpPid=$!
	echo "increase priority of rsync"
    renice --priority -10 --pid ${cpPid}
    wait $!
    echo -e "\t${delim}\nTerminating timer\n\t${delim}"
    kill ${pid}
    date
} # end copyImage()

# diff using rsync dry run do show differences
# rsync SRC DEST
function rsyncDiff() {
    SRC=${1}
    DEST=${2}
    echo "DEBUG: --exclude=.bash_history, also use '-x' option to avoid crossing mount point"
    echo "Differences between  ${SRC} ${DEST}, this takes about 2 minutes"
    date
    time rsync --exclude=.bash_history --exclude="genesis*sqlite" -rlcnv ${SRC} ${DEST}
    date
} # end rsyncDiff()


if (( $# < 1 ))
then
  usage
fi

checkUser
doExit=0
Finalize=0
Umount=0
while getopts "i:b:mudF" arg;
do
case ${arg} in
  i)
	cardimg=${OPTARG}
 	;;
  b)
	mntdir=${OPTARG}
 	;;
  m)
	if [ ${doExit} -eq 0 ]
	then
		doMount
        	doExit=1
	fi
	;;
  u)
	Umount=1
	doExit=1
	;;
  d)
	if [ ${doExit} -eq 0 ]
	then
		setupBldPath
		rsyncDiff  ${mntdir}/ ${bldPath}/
		doExit=1
	fi
	;;
  F)	# call genperms and dogtag update
	Finalize=1
	doExit=1
	;;
esac
done

# update the home directory permissions and the dogtag before
# unmounting the image
if [ $Finalize -gt 0 ] ;then finalizeImage ;fi
if [ $Umount -gt 0 ] ;then doUmount ;fi

if [ ${doExit} -gt 0 ]
then
   exit 0
fi

#  sdcard-xxxxxx.img
doMount
copyImage

#rsyncDiff  ${mntdir}/ ${bldPath}/
#rsyncDiff  ${bldPath}/ ${mntdir}/ 

# to package up
# set perms, and generate etc/dogtag
#~exodus/app/genperm.sh ${mntdir}

# update tar dir with img changes
# remove 'n' dryrun, do for real this time
# add 'p' to preserve permissions
#time rsync --exclude=.bash_history --exclude="genesis*sqlite" -xrplcv ${mntdir}/ ${bldPath}/
# USE -x  or --one-file-system to avoid crossing mnt point, zero .img then populate (use 'dd')
# USE --exclude=.bash_history
#    dd if=/dev/zero of=/zero
#    sync


# need to unmount the loop back before compressing
#umount ${mntdir}

# compress image
# then 'renice' to higher priority, compressing takes a long time
# make sure img is NOT mounted before compressing, else the image is corrupted
# if mount |grep ${mntdir}
# then
#   echo "${mntdir} still mounted, unmounting"
#    mount |grep img
#   umount ${mntdir}
# fi

# echo "this can take close to an hour"
# faster to copy to windows box (3 minutes) and 
# compress there in about 6 minutes with threaded xz (xz -T 0 *.img). 
#time xz ${cardimg}
#renice --priority -5 --pid $(pgrep xz)

####### extract smarten tar
#
#time tar -xvf ${smartenFile}

# extract smarten tar to /build
# tar -C /build/rootfs-20220526 -xf /home/exodus/tmp/smarten-5.0.0.33.4251.tar.xz
