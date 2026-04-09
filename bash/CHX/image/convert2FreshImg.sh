#!/bin/bash
#################################
# ChampionX 2026
# Take an existing update function sdcard image and convert it to a fresh install function image.
# The converted image is rename with "fresh" in the name.
#################################

##############
#
# insert "-fresh" in the file name just before the 'img' suffix
##############
function convertName(){

 echo ${convImage} | sed 's/.img/-fresh.img/'

} # end convertName()

convImage=${1}
convImageFresh=$(convertName)
noXZconvImageFresh=$(echo ${convImageFresh} |sed 's/.xz//')
mounted=0
IMGMNT=/mnt/frimg
mkdir -p ${IMGMNT}
HERE=${PWD}

# check if the image is already mounted
mntImage=$(mount -t ext4 |grep .img|awk '{i=index($1,"sdcard");print substr($1,i)}')

if [ ${#mntImage} -gt 0 ] 
then
    if [ ${mntImage} != ${noXZconvImageFresh} ]
    then
    	echo "Need to unmount current image ${mntImage} before creating fresh"
    	echo "Run ./imgBuild.sh -i ${mntImage} -b /mnt/img -u"
    	exit 1
    else
        mounted=1
	echo "Using already mounted ${noXZconvImageFresh}"
    fi
fi

if [ ${#} -lt 1 ]
then
   echo "USAGE: ${0} sdcard-YYMMDD-x.x.x.img[.xz]"
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


if [ ! -e ${convImageFresh} ]
then
	echo "Making a copy of ${convImage} to ${convImageFresh}, this can take several minutes."
	echo "Current available space"
        df -h .
	cp ${convImage} ${convImageFresh}
else
	echo " ${convImageFresh} already exists."
        read -p "Use this image? [y]|n " ans
        if [ ${#ans} -eq 0 ] || [ ${ans} = "y" ] 
        then
	   echo "use image"
	else
		exit 1
	fi
fi

if [ ${mounted} -eq 1 ]
then
   echo " ${convImageFresh} already mounted "
else
   ${SUDO} ./imgBuild.sh -i ${convImageFresh} -b ${IMGMNT}  -m
fi

uDefault=/etc/pcsf/default/uenv.zero
uRootSymlk=/mnt/img/uEnv.txt
uBootLoc=/boot/uEnv.txt
if file /bin/bash |grep -q ARM
then
	# chroot to image and put "fresh install" uEnv.txt in place in /boot of image"
cat <<-EOF |${SUDO} chroot ${IMGMNT}
cp ${uDefault} ${uBootLoc}
chmod 644 ${uBootLoc}
EOF
else
	cd ${IMGMNT}
	cp ${uDefault/\//} ${uBootLoc/\//}
	chmod 644 ${uBootLoc/\//}
	cd ${HERE}
fi
echo "unmounting ${convImageFresh}"
./imgBuild.sh -i ${convImageFresh} -b ${IMGMNT} -u
