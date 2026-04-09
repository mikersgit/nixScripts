#!/bin/bash

if [ $# -lt 1 ]
then
	echo "USAGE: ${0##*/} <file to publish>"
	echo "   eg. ${0##*/} kernel-23114.img"
	echo "This rsyncs over ssh the specified file to exodus.center."
	exit 1
fi
fl=$1
# ecenter is exodus.center and is exported in the .bashrc at login
ecenter=50.116.29.158
dhost=${ecenter}
duser='exodus'
case ${fl} in
	sdcard*) path="/usr/local/www/files/sd_card/";;
	rootfs*) path="/usr/local/www/files/iotbone/";;
	userdata*) path="/usr/local/www/files/iotbone/";;
	kernel*) path="/usr/local/www/files/iotbone/";;
	SystemUpdate*) path="/usr/local/www/files/usb_image/";;
	qfil*) path="/usr/local/www/files/genesis/";;
	*deb) path="/usr/local/www/files/dpkg/";;
esac
echo "push ${fl} to ${path} on ${duser}@${dhost}."
#rsync -e "ssh -i ~/src/mwr_rsa -p 2730" --partial --append --progress  ${fl} ${duser}@${dhost}:${path}.
rsync -e "ssh -i $SRC/mwr_rsa -p 2730" --partial --append --progress  ${fl} ${duser}@${dhost}:${path}.
 "Or add direct entries \"<IP> <hostname>\" in /etc/hosts"
		exit 1
	fi
}

verifyConnection $ecenter

echo "push ${fl} to ${path} on ${duser}@${dhost}."
#rsync -e "ssh -i ~/src/mwr_rsa -p 2730" --partial --append --progress  ${fl} ${duser}@${dhost}:${path}.
rsync -e "ssh -i $SRC/mwr_rsa -p 2730" --partial --append --progress  ${fl} ${duser}@${dhost}:${path}.
