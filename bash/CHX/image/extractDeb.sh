#!/bin/bash
#
# given a debian package file, extract into a like named directory
#
# make sure the exodus user exists
if ! grep -q exodus /etc/passwd
then
	sudo adduser --uid 1001 -gid 100 exodus
fi
if [[ $# -lt 1 || ! -e $1 ]]
then
	echo "USAGE: ${0} <debian pakcage>"
	echo "example: ${0} smarten-system_6.1.deb"
	exit 1
fi
deb=$1
debDir=${1%*.deb}
echo "Extracting $deb to $debDir"
echo "=========================="
dpkg-deb -R $deb $debDir
ls -l $debDir
