#!/bin/bash
ToolsDeb=smarten-imagetools_1.0.8_all.deb
if [[ $# -lt 1 ]]
then
	echo "eg. ${0##*/} ${ToolsDeb}"
	exit 1
fi

if [[ $# -lt 1 ]]
then
	echo "eg. ${0##*/} ${ToolsDeb}"
	read -p "Image tools debian file name: " SMdeb
else
	SMdeb=$1
fi

WWWhost=exodus.center
URLS=( https://${WWWhost}/files/misc/dpkg/${SMdeb})

verifyConnection() {
	ret=$(ping -q -c 2 -i 2 $1 &>/dev/null ;echo $?)
	if [ $ret -gt 0 ];then
		echo "Cannot reach $1"
		echo "Make sure you have a default gateway"
		echo "To check: $ ip r"
		echo "To add gateway: $ ip r add default via 192.168.0.1"
		echo "Or add direct entries \"<IP> <hostname>\" in /etc/hosts"
		exit 1
	fi
}

verifyConnection ${WWWhost}

for f in ${URLS[@]}
{
        wget --no-check-certificate $f
}

if [ -e ${SMdeb} ]; then
	dpkg --force-overwrite -i ${SMdeb}
	if [[ -x /build/image/installSmartenImage.sh ]];then
		cd /build/image
		/build/image/installSmartenImage.sh
	else
		echo "ERROR: installSmartenImage.sh not found"
	fi
fi
