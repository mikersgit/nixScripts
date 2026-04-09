#!/bin/bash
DT=$(date '+%Y%j')
AvailBuild=$(ls -d smarten-system*all |tail -1)
Firmware=$(ls -1rt smarten-*tar.xz |tail -1 |cut -d "." -f 1-4 |sed 's/smarten-//')
if [ $# -lt 2 ]
then
	echo "USAGE: ${0##*/} <DirToPackage> <PackageName>"
	echo "   e.g. ${0##*/} ${AvailBuild} smarten-system_${Firmware}.${DT}_all.deb"
	exit 1
fi
if ! grep -q exodus /etc/passwd
then
        sudo adduser --uid 1001 -gid 100 exodus
fi
buildDir=$1
packageName=$2
dpkg-deb -Z xz -b $buildDir $packageName
