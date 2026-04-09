#!/bin/bash

CONFFILE="compare.conf"

function SaveConfig() {
	echo "dpkgdir=${dpkgdir}" > ${CONFFILE}
	echo "GITSRC=${GITSRC}" >> ${CONFFILE}
	echo "Config saved to ${CONFFILE}"
}

function SetAction() {
	if [ ${#action} -gt 2 ];then
		echo "Action: $action"
	else
		action=""
		echo "Action: md5sum compare only"
	fi
}

function usage() {
	echo "Either specifiy directories and action:"
	echo "${0##*/} [<extracted Debian package dir> <git repo dir> [copy|diff]]"
	echo "Or be prompted for the values"
	echo "${0##*/}"
	exit 1
}

if [ -e ${CONFFILE} ] ;then
	source ${CONFFILE}
fi

if [ $# -eq 1 ] ;then
	usage
fi

if [ $# -eq 0 ] ; then
	if [ ! -e compare.conf ] ; then
		read -p "Debian package directory: " dpkgdir
		read -p "Git directory: " GITSRC
		SaveConfig
	fi
	read -p "Action [copy|diff|(md5sum compare)]: " action
	SetAction
else
	dpkgdir="${1}"
	GITSRC="${2}"
	SaveConfig
	if [ $# -gt 2 ];then
		action=$3
	fi
	SetAction
	#GITSRC=/mnt/c/Users/20801921/source/repos/rootfs/current
fi

echo "Dpkg psuedo root: ${dpkgdir}"
echo "Git repo root: ${GITSRC}"
read -t 3 -p "..."
echo ""
cd "${dpkgdir}"
for f in $(find . -type f ! -path \*Engine\* \
       	! -path \*GenesisMcp\* \
       	! -path \*SmartenClient\* \
       	! -path \*SmartenServer\* \
       	! -path \*exodus/app\* \
	! -path \*exodus/lib\*)
{
	a=$(md5sum $f|cut -d " " -f1,1)
	#GitFile=$GITSRC/${f##*$dpkgdir}
	GitFile=$GITSRC/${f#./*}
	if test -e ${GitFile}
	then
		b=$(md5sum $GitFile|cut -d " " -f 1,1)
		if [[ $a = $b ]]
		then
			#echo "same"
			:
		else
			echo -e "\t${f#./*} not the same"
			if [ ${#action} -gt 0 ];then
				case ${action} in
					"copy")
						echo "copying $f to $GitFile"
						cp -i $f $GitFile;;
					"diff")
						echo "diff $f to $GitFile"
						diff -s $f $GitFile;;
					*) echo "Action: ${action} not recognized"
						exit 1;;
				esac
			fi
		fi
	else
		echo " $GitFile does not exist"
		b=$a
	fi
}
