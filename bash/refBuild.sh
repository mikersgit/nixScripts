#!/bin/bash

#
# script to generate a new ISO from latest code
# updates code,
# cleans previous build artifacts
# does fresh build
#
# assumes that sitting at top of code tree (fmt_0)
######

tt='fmt_0'
parent=${PWD##*/}
prog=${0##*/}
progBase=${prog%\.*}
rmtar=0
CLEAN='make -j clean'

function usage() {
	echo "usage: ${1} [-mr]"
	echo "   m  -- minimize the size of build artifacts"
	echo "   r  -- rebuild over existing artifacts, no 'make clean'"
	exit 2
}

while getopts :mr OPT; do
    case $OPT in
	m)
	        rmtar=1
	;;r)
	        CLEAN=""
	;;*)
                usage ${0##*/}
    esac
done
shift $[ OPTIND - 1 ]

(( $# > 0 )) && usage

if [[ ${parent} != ${tt} ]]
then
        # try to get to the top of the tree
        trytree="${PWD%/${tt}/*}/${tt}"
        if [[ ! -d ${trytree} ]] 
        then
                echo "Parent directory, '${parent}',  isn't '${tt}'"
                echo "Could not get to '${tt}' in the current tree"
                exit 1
        else
                cd ${trytree}
        fi
fi

echo "OK to build"
if [[ ! -d ~/logs ]]
then
        mkdir ~/logs
fi

LOG=~/logs/${progBase}.log

date > ${LOG}
(pwd;svn info
time svn up
time ${CLEAN}
time make pkgfull) 2>&1 | tee -a ${LOG}
date >> ${LOG}

if (( rmtar ))
then
        cd pkg
        rm -rf pkg*.tar RPMS/x86_64/* ibrix/distrib/IBRIX/RHEL5/x86_64/*
fi
