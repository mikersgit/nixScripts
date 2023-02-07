#!/bin/bash
# exodus@geneng.oilgas.center
cdev=199.180.249.167
port=2730
user=exodus
libdir=exodus/Clibs/libRIB2
key='/cygdrive/c/users/20801921/OneDrive - ChampionX/Documents/access/mwr_rsa'
file="${1}"
scp -i "${key}" -P ${port} ${file} ${user}@${cdev}:${libdir}/
ssh -i "${key}" -p ${port} ${user}@${cdev} "./mklib.sh"
