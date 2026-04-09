#!/bin/bash
#
# script to print out all the commit messages from a particular date. Helpful for creating the
# README for the download website
######
if [[ $# -lt 1 ]]; then
	echo "Supply date from which to print commit messages"
	echo "date format is 'YYYY-MM-DD'"
	exit 1
fi
sdate=${1}
git log --since=${sdate} | grep -v -e ^commit -e ^Author -e ^Date -e ^$
