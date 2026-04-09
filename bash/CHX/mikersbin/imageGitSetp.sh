#!/bin/bash

# /etc/hosts entry
# 13.107.42.18  spiritnps.visualstudio.com
function cleanup() {
	local gdir=$1
	rmlist=($2)
	cd ${gdir}
	git config credential.helper store
	find . -name tags -exec rm -rf {} \;
	if [ $# -gt 1 ]
	then
		rm -rf ${rmlist[*]}
	fi
	cd ..
}
git clone https://spiritnps.visualstudio.com/rootfs/_git/rootfs
cleanup rootfs "next"

git clone https://spiritnps.visualstudio.com/ExodusCapps/_git/Exodus
cleanup Exodus 

git clone https://spiritnps.visualstudio.com/OS/_git/OS
cleanup OS "ekioh"
