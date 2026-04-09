#!/bin/bash
# cygwin method of writing *.img file to sdcard
# powershell to list devices "Get-WmiObject Win32_diskdrive"
# NEEDS WORK
# writes to the card, but doesn't boot

BlockSize="4k"
imgFile=${1}
if [ ${#imgFile} -lt 1 ]
then
	echo "	Need image name"
	exit
fi
echo "List of non-C mounted disks"
cat /proc/partitions |awk '{if (NF > 4 && $5 !~ "^C") print}'
read -p"Disk name (not the /dev part): " dsk
DSK=/dev/${dsk}
if [ ${#dsk} -lt 1 ]
then
	echo "	Need disk name"
	exit
else
	ls -l ${DSK}
	echo "Write ${imgFile} to ${DSK}"
	dd if=${imgFile} of=${DSK} bs=${BlockSize}
fi
