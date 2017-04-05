#!/bin/bash

# Script to skip first N lines of file, the print remaining lines.

function usage() {
        echo -e "\nusage: ${1} SkipCnt file"
        echo -e "Skips the first 'SkipCnt' lines of file,\c "
        echo -e " then prints remaining lines."
        exit 1
}

# need two arguments
(( $# < 2 )) && usage ${0##*/}

c=$1;fl=$2

# make sure skip count is a number
! (echo ${c}                    |
        grep -e ^[[:digit:]]    |
        grep -e [[:digit:]]$ >/dev/null) &&
   usage ${0##*/}

# make sure cnt is positive number
(( ${1} < 0 )) && (( c=${1}*-1 ))

# make sure file exists
[[ ! -e ${fl} ]] && usage ${0##*/}

awk -v c=${c} 'BEGIN {i=1;rc=1}
        {while (i<=c && rc==1) {
                rc=getline
                i++
        }
                if (i>c && rc) print
        }' ${fl}
exit 0
