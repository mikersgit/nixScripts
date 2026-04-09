#!/bin/bash
#
# Install Smarten Image tools and its dependencies that are extracted from tar file
# https://exodus.center/files/misc/dpkg/SmartenImageDeps.tar

## perl and its dependencies
dpkg -i *perl*deb

## git and its dependencies
dpkg -i git*deb

#setup target folder in userdata so as to not overfill rootfs
if [[ ! -e /data/build ]];then
	mkdir /data/build
	ln -s /data/build /build
	mkdir /build/image
fi
## Smarten image tools and its dependencies
dpkg -i smarten-imagetools*deb
