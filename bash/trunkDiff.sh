#!/bin/bash

#
# script to show a summary of differences between a working copy branch and its base

# default module name
baseModule='fmt_0'

#
# usage message
#
function usage() {
	echo "usage: ${1} [-m moduleName]"
	echo -e "\t\t-m ModuleName Default is ${baseModule}"
	exit 2

} # end usage()

while getopts :m: OPT; do
    case $OPT in
	m|+m)
	baseModule="$OPTARG"
	;;*)
	usage ${0##*/}
    esac
done
shift $[ OPTIND - 1 ]

# get the pattern of the path leading up to the base module so that can be ignored
baseDir=$(echo ${PWD%${baseModule}*} | awk '{c=split($0,ary,"/"); print ary[(c-1)]}')

# build the URL abbreviation for the base relative to current directory
baseUrl="^/trunk${PWD##*${baseDir}}"

# get the URL for the current working copy
wrkCopy="$(grep ${baseModule} .svn/entries )"

echo -e "Summary of diffs between:\n${baseUrl}\n\tand\n${wrkCopy}"

# display summary of differences between base and working copy
svn diff --summarize ${baseUrl} ${wrkCopy}


