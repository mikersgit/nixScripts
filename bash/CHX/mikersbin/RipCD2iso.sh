#!/bin/bash
# look in file explorer for the drive letter to mount 'F:' in this case
DRIVE='F'
ISO='Ripped.iso'
if [[ ! -e /mnt/${DRIVE} ]] ; then
	sudo mkdir /mnt/${DRIVE}
fi
sudo mount -t drvfs ${DRIVE}: /mnt/${DRIVE}
mkisofs -max-iso9660-filenames -o Ripped.iso /mnt/${DRIVE}
sudo umount /mnt/{DRIVE}
echo 'double click "Ripped.iso" to verify it mounts as a disk and is readable'
