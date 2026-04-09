#!/bin/bash
# download to the current directory
# the directory must be writable by user "_apt", easiest to just "chmod 777"
apt-get download gdisk

# install to the mount location of the disk image
dpkg --root=/mnt/timg/ -i gdisk_1.0.1-1_armhf.deb
