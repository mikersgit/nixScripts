#!/bin/bash

# script to run Coverity analysis on a sub-tree of fmt0

# ias/cpp - use defaults (C/C++)
# ias/modules - use java static
# fs - use defaults
# tools/ibrcfr - use defaults

#BASE='/root/source/bug13118/fmt_0/fmt_0'

# source in the message printing function
# assumes entire 'mwroberts/bin' directory is available
#
cmdDir=${0%/*}
if [[ ${cmdDir} = ${0} ]]
then
        cmdDir='.'
fi

. ${cmdDir}/msg.source

# Assume running from 'fmt_0'
#
BASE=${PWD}
DB='/var/coverity/coverityDM'

# available code types used for analysis phase
#
cType=' '     # default C/C++
jType='-java' # java

##
## Available sub-trees to build. Just add a ARGS[N] entry to add more trees
##
##
##  'tools/ibrcfr:'${cType}':/var/coverity/coverityIB:IBRIX'
##        |            |             |                 +- product in Coverity DB
##        |            |             +- build analysis directory
##        |            +- C/C++ (cType), or Java (jType)
##        +- path from fmt_0
##
ARGS[0]='tools/ibrcfr:'${cType}':/var/coverity/coverityIB:IBRIX'
ARGS[1]='ias/cpp:'${cType}':/var/coverity/coverityIB:IbrixIasCpp'
ARGS[2]='ias/modules:'${jType}':/var/coverity/coverityIB:IbrixIasMod'
ARGS[3]='fs:'${cType}':/var/coverity/coverityIB:X9kFS'
ARGS[4]='tools:'${cType}':/var/coverity/coverityIB:X9kTools'

# for regular builds 2048m is OK for java builds. When building for Coverity
# double it to 4096
#
function javaCleanup() {

	# kill any lingering old coverity java procs
	#
	pids=$(ps -ef | grep java | grep coverit |awk '{print $2 " " $3}')
	(( ${#pids} > 0 )) && ( kill ${pids} ;sleep 3 ; kill -9 ${pids} )

	# modify maven opts in Makefile
	#
	mepid="m"$$
	sed 's/2048m/4096m/' Makefile > ${mepid} 
	[[ -s m ]] && /bin/mv ${mepid} Makefile
	rm -f ${mepid} 
}

# Run coverity build/analysis/commit based on parameters for each sub-tree
#
function covrun() {

	subDir=$(echo ${@}| cut -d":" -f 1)
	aType=$(echo ${@}| cut -d":" -f 2)
	ibDir=$(echo ${@}| cut -d":" -f 3)
	prod=$(echo ${@}| cut -d":" -f 4)

	cd ${BASE}/${subDir}

        msg "Coverity run of  ${BASE}/${subDir}"
        msg "Product: ${prod}\nDatabase: ${DB}"

	javaCleanup
	make clean 
	rm -rf ${ibDir}
	if cov-build --dir ${ibDir} make
	then
		if cov-analyze${aType} --dir ${ibDir}
		then
			cov-commit-defects --datadir ${DB} \
		   		--product ${prod} \
		   		--user admin --dir ${ibDir}
			make clean ; make
		fi
	fi
}

function listMods() {
    echo "module numbers to be passed to '-m' command line options"
    for ((i=0;i<${#ARGS[*]};i++))
    {
	echo " ${i} - $(echo ${ARGS[${i}]}|sed 's/:/ /g')"
    }
    exit 0
}

function usage() {
	echo "usage: ${1##*/} [-P <base source path>] [-m <module number>] [-?h]"
	echo -e "\t P - path to source,including fmt_0. e.g. /root/source/fmt_0.\n\t     Def: PWD - ${PWD}"
	echo -e "\t m - the ids of the known sub-trees to analyze. e.g. '-m 0 -m 2'"
	echo -e "\t l - list the valid module ids for use with -m"
	listMods
	exit 1
}

MODS=''
i=1
while getopts :lP:m:?h OPT; do
    case $OPT in
	P|+P)
	BASE="$OPTARG"
	;;m|+m)
	MODS[${i}]="$OPTARG"
	((i+=1))
        ;;l) listMods; exit 0
	;;*)
	usage ${0##*/} ; exit 1
    esac
done
shift $[ OPTIND - 1 ]

for ((i=1;i<=${#MODS[*]};i++))
{
    covrun ${ARGS[${MODS[${i}]}]}
}
