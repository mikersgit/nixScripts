#!/bin/bash
# exodus@geneng.oilgas.center
cdev=199.180.249.167
port=2730
user=exodus
libdir=Clibs/libRIB2
key='/cygdrive/c/users/20801921/OneDrive - ChampionX/Documents/access/mwr_rsa'
if [[ $# < 2 ]]
then
	echo "USAGE: ${0} <file to push> <Src Dir on host to build>"
	echo " eq. ${0} analogDigital.c is4903/Exodus"
	exit 1
fi
file="${1}"
srcdir="${2}"
scp -i "${key}" -P ${port} ${file} ${user}@${cdev}:${srcdir}${libdir}/
ssh -i "${key}" -p ${port} ${user}@${cdev} "./mklib.sh ${srcdir}"
