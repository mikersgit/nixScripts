#!/bin/bash
if [ ${#} -lt 3 ]; then
	echo "${0##*/} <repo> <proj> <passToken>"
	echo "eg. ${0##*/} Exodus ExodusCapps fh4byztkspniytt5tm6fo4ff6j3assvsxnmrjyxyx5nd5mitcw6a"
	echo "eg. ${0##*/} rootfs rootfs fh4byztkspniytt5tm6fo4ff6j3assvsxnmrjyxyx5nd5mitcw6a"
	exit 1
fi
repo=$1
proj=$2
pass=$3

path=https://spiritnps.visualstudio.com/${proj}/_git/${repo}
#pass=fh4byztkspniytt5tm6fo4ff6j3assvsxnmrjyxyx5nd5mitcw6a
user=michael.roberts
echo "repo path $path"
echo $pass" "$user
git clone ${path}
echo -e "$(date)\n$path\n$user\n$pass" >> ${repo}Creds
cd ${repo}
git config credential.helper store
