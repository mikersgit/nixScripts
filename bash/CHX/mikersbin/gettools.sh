#!/bin/bash
ToolsDeb=smarten-imagetools_1.0.4_all.deb
ToolsTar=SmartenImageDeps.tar.xz
if [[ $# -eq 1 ]]
then
	echo "eg. ${0##*/} ${ToolsDeb} ${ToolsTar}"
	exit 1
fi
if [[ $# -lt 1 ]]
then
	echo "eg. ${0##*/} ${ToolsDeb} ${ToolsTar} [On separate lines at prompts]"
	read -p "Image tools debian file name: " SMdeb
	read -p "Smarten image dependencies file name: " SMim
else
	SMdeb=$1
	SMim=$2
fi
URLS=( https://exodus.center/files/misc/dpkg/${SMdeb}
https://exodus.center/files/misc/dpkg/${SMim})
for f in ${URLS[@]}
{
        wget $f
}
if [ -e ${SMim} ]; then
        tar -xvf ${SMim}
	if [[ -x ./installSmartenImage.sh ]];then
		./installSmartenImage.sh
	else
		echo "ERROR: installSmartenImage.sh not found"
	fi
else
        echo "ERROR: File ${SMim} not retrieved"
        exit 1
fi
 entries \"<IP> <hostname>\" in /etc/hosts"
		exit 1
	fi
}

verifyConnection ${WWWhost}

for f in ${URLS[@]}
{
        wget $f
}
if [ -e ${SMim} ]; then
        tar -xvf ${SMim}
	if [[ -x ./installSmartenImage.sh ]];then
		./installSmartenImage.sh
	else
		echo "ERROR: installSmartenImage.sh not found"
	fi
else
        echo "ERROR: File ${SMim} not retrieved"
        exit 1
fi
