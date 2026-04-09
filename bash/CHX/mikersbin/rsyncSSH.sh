#!/bin/bash
if echo $HOME|grep -q mikers
then
	HMpath='/mnt/c/cygwin64/home/20801921/src'
else
	HMpath=${HOME}'/src'
fi

if [ $# -lt 3 ]
then
	echo "USAGE: ${0##*/} <local file to push> <remote host> <path on remote host>"
	echo "			remote user is assumed to be 'exodus'"
	exit 1
fi
fl=$1
dhost=${2}
path=$3
duser='exodus'
echo "push ${fl} to ${path}/${fl} on ${duser}@${dhost}"
rsync -e "ssh -i ${HMpath}/mwr_rsa -p 2730" --partial --append --progress  ${fl} ${duser}@${dhost}:${path}/${fl}
