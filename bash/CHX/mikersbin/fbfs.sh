#!/bin/bash
#FB="/cygdrive/c/Users/20801921/OneDrive\ -\ ChampionX/Apps/TbonePrograming/platform-tools/fastboot"
#FB="/home/20801921/programTbone/fastboot"
FB="/mnt/c/cygwin64/home/20801921/programTbone/fastboot.exe"
IMGs=(rootfs kernel emmc splash userdata)
PARTs=(system boot aboot splash userdata)
IMG=${1}
Reboot=${2}
PART=''

if [ ${#} -lt 1 ]
then
	echo "USAGE: ${0##*/} <img file> [reboot]"
	echo "   eg. ${0##*/} kernel-23111.img reboot"
	echo "   This would flash kernel to boot and reboot"
	exit 1
fi

i=0
for img in ${IMGs[@]}
{
	if echo ${IMG} |grep -q ${img}
	then
		PART=${PARTs[${i}]}
		break
	fi
	((i+=1))
}

if [ ${#PART} -lt 2 ]
then
	echo "No partition ${IMG} found"
	exit 1
fi
echo "Flashing ${IMG} to partition ${PART}"

${FB} devices
${FB} flash ${PART} ${IMG}
if [ ${#Reboot} -gt 0 ]
then
	echo "Rebooting device"
	${FB} reboot
fi
