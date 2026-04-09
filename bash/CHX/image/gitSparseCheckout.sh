#!/bin/bash
#Script for rootfs to only checkout one image dir either "current"
#or "winchester"
#default is "current"
#Also checkout OS Exodus BBB_kernel and TBone repos
#
if [[ ${#} -lt 1 ]]
then
	echo "USAGE: ${0##*/} current|winchester"
	exit 1
else
	rfssubtree=${1}
fi

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

source TOKEN.src
repos=(rootfs Exodus OS TBone BBB_Kernel)
repoPaths=(rootfs ExodusCapps OS TBone BBB_Kernel)
repoSparse=(sparse sparse sparse sparse sparse)
repoSubtree=(${rfssubtree} Clibs/libRIB2 hmi.qt5 flash/tools src/kernel4/drivers/gpio)
azureHost=spiritnps.visualstudio.com
azureBaseUrl="https://${USER}:${TOKEN}@${azureHost}"
echo $azureBaseUrl

verifyConnection $azureHost

#
# initialize and pull git repos, checkout sparse if indicated
#
function initGitDir() {
	local frepo=$1
	local frepoPath=$2
	local cpwd=${PWD}
	local sparse=$3
	local subtree=$4
	echo "========================="
	echo "== ${frepo} ${sparse} ========="
	echo "========================="
	if mkdir ${frepo} 2>/dev/null ;then
		:
	else
		echo "dir ${frepo} already exists"
	fi
	cd ${frepo}
	if test -d .git
	then
		echo "Already a git repo, no need to initialize"
		echo "Attempting 'pull'"
		git pull origin master
	else
		git init
		git remote add -f origin ${frepoPath}
		git config credential.helper store
		if test -n ${sparse} ;then
			git config core.sparseCheckout true
			echo "${subtree}/" > .git/info/sparse-checkout
			echo "#########################"
			echo "## ${subtree} #########"
			echo "#########################"
		fi
		git pull origin master
	fi
	cd ${cpwd}
}

git config  --global user.name michael.roberts

echo "clone/update repos ${repos[@]}"
read -p "Continue? [N]|Y " ans
i=0
if [[ ${ans} = [yY] ]]
then
	if test -e ${HOME}/.git-credentials ;then
		cat ${HOME}/.git-credentials
		echo "==============="
	fi
	if ls *[Cc]red* >/dev/null 2>&1 ;then
		echo "Any credential files of the form <repo>[Cc]red"
		cat *[Cc]red*
	fi
	for r in ${repos[@]}
	{
		fullpath=${azureBaseUrl}/${repoPaths[$i]}/_git/${repos[$i]}
		sparse=${repoSparse[$i]}
		subtree=${repoSubtree[$i]}
		initGitDir ${r} ${fullpath} ${sparse} ${subtree}
		((i+=1))
	}
	echo "May need to do additional git config like:"
	echo "git push --set-upstream origin master"
	echo "git branch --set-upstream-to=origin/master master"
else
	echo "No cloning of ${repos[@]}"
fi
