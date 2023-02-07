#!/bin/bash

############################
# ChampionX 2022
# open up an existing sdcard install image to allow changes to the operating system and/or the Smarten firmware image.
# The methodology is to copy the contents of the OS and firmware to /build/rootfs-<version>, make changes there, then copy
# the contents of the /build/rootfs-<version> back to the mounted image.
############################

dstr='+%H:%M:%S'
cardimg=${1}
delim='========='
prog=${0}
mntdir=/mnt/img
bldDir=/build

function usage() {
   echo "USAGE: ${prog} sdcard-YYYYMMDD.img[.xz] [-m|u|d]"
   echo "       Without options, the image is mounted, and a copy is made to /build/rootfs-..."
   echo "   -m  Only mount the image, do not copy."
   echo "   -u  Fill empty space in image with zeros to improve compression, then Unmount the image."
   echo "   -d  Diff the image and the corresponding /build/rootfs-..."
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
    idstr=$(echo ${cardimg}| cut -d "-" -f 2 |cut -d "." -f1)
    bldPath=${bldDir}/rootfs-${idstr}
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

function doMount() {
    checkImg
    setupDirs
    mount -o offset=1048576 ${cardimg} ${mntdir}
    df ${mntdir}
} # end doMount()

function zeroOut() {
    # writing zeros to the mount point empty space makes the
    # image compress better
    echo "zero-ing out free space on mounted image ${1}"
    outfile=${1}/zero
    dd bs=8K if=/dev/zero of=${outfile}
    sync ${1}
    rm ${outfile}
} # end zeroOut()

function doUmount() {
    zeroOut ${mntdir}
    umount ${mntdir}
    df
} # end doUmount

##########
function copyImage() {
    echo "Copying mounted sdcard image to ${bldPath}, this can take up to 10 minutes."
    date
    timer &
    pid=$!
    #time cp -a ${mntdir}/* ${bldPath} &
    time rsync --exclude=.bash_history --exclude="genesis*sqlite" -rlc ${mntdir}/* ${bldPath} &
    cpPid=$!
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

case ${2} in
  '-m')
	doMount
	exit 0
	;;
  '-u')
	doUmount
	exit 0
	;;
  '-d')
	setupBldPath
	rsyncDiff  ${mntdir}/ ${bldPath}/
	exit 0
	;;
esac

#  sdcard-xxxxxx.img
doMount
copyImage

rsyncDiff  ${mntdir}/ ${bldPath}/
rsyncDiff  ${bldPath}/ ${mntdir}/ 

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
