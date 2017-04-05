#!/bin/bash

# Command to update source trees and then generate doxygen analysis
# to web visible directories.
#
# The Doxygen config files rely on these variables being
# exported in the shell.
# # path excluding the repo name
# export INPUT_BASE="${gsrcs[$i]%/${HPSMB}}"
# # path where the doxygen conf files live
# export OUTPUT_BASE="${gouts[$i]}"
#

if (( $# > 0 ))
then
    dtype=${1}
else
    dtype='a'
fi

prog=${0##*/}
bprog=${prog%.*}
pdir=${0%/*}
if [[ ${prog} = ${pdir} ]]
then
    CONF="${bprog}.conf"
else
    CONF="${pdir}/${bprog}.conf"
fi

#
# print banner with stars
#
function msg(){
	local cnt=${#1}; local sline=''; local c
	# create line of stars 4 longer than length of first argument to msg
	for ((c=1;c<=(cnt+4);c++)); { sline=${sline}'*'; }
	echo -e "\n\t${sline}\n\t* ${@}\n\t${sline}\n"
} # end msg()

# source in the configuration details
if [[ -f ${CONF} ]]
then
    . ${CONF}
else
    msg "ERROR: no conf file ${CONF}"
    exit 2
fi

LOG="${logBase}/${bprog}$(date '+%u').log"
\rm ${LOG}

function callDox() {
    dir=${1}
	cd ${dir}
	for f in $(ls Doxyfile_[kdfitlns]*)
	{
		msg "Processing $f in ${dir}" >>${LOG} 2>&1
		${DOXYGEN} ${f} >>${LOG} 2>&1
	}
} # end callDox()

function doSVN() {
        # update svn sources
        for s in ${ssrcs[*]}
        {
            cd ${s}
            msg "Updating source in ${s}" >>${LOG} 2>&1
            svn up >>${LOG} 2>&1
        }
        for d in ${souts[*]}
        {
            callDox ${d}
        }
} # end doSVN()

function doGIT() {
        # update git sources
        for d in ${gsrcs[*]}
        {
            cd ${d}
            msg "Updating source in ${d}" >>${LOG} 2>&1
            git pull --rebase >>${LOG} 2>&1
        }

        local i=0
        for d in ${gouts[*]}
        {
            # INPUT_BASE is needed to provide the input source location
            # for the Doxyfile_* files so they are generic across
            # iterations.
            # OUTPUT_BASE make them generic across repos
            msg "INPUT SOURCE=${gsrcs[$i]}" >>${LOG} 2>&1
            msg "INPUT_BASE=${gsrcs[$i]%/${HPSMB}}" >>${LOG} 2>&1
            msg "OUTPUT_BASE=${gouts[$i]}" >>${LOG} 2>&1
            export INPUT_BASE="${gsrcs[$i]%/${HPSMB}}"
            export OUTPUT_BASE="${gouts[$i]}"
            callDox ${d}
            ((i+=1))
        }

} # end doGIT()

case ${dtype} in
    s)
        doSVN
        ;;
    g)
        doGIT
        ;;
    a)
        doSVN
        doGIT
        ;;
esac
