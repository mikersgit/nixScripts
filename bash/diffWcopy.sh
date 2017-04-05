#!/bin/bash

# diff two SVN working copies that differ in path by only the parent
# directory. It is assumed that the script is executed in a directory
# of one working copy, and the diff should be at that level and below.
# Path examples
# WC1: /svn/src/branch1/d1/d2
# WC2: /svn/src/branch2/d1/d2
# and PWD = /svn/src/branch2/d1/d2
# diff would be WC1's d2 and WC2's d2
# The script can generate
#   - the diffs to the screen,
#   - or diff commnds to the screen
#   - or vimdiff commands to the screen
#   - or patch files for every diff found
#####################################################################

####
# contents of diffExclude file
# .svn
# *.[oadl1]
# *.lo
# *.la
# *.so
# cscope*
# tags
# eTags
##########

function usage() {
    ECHO="echo -e"
    ${ECHO} "usage: ${1} -b branch -[d|v|p|c]"
    ${ECHO} "\t\t\t-b br\tthe part of the source path that differs"
    ${ECHO} "\t\t\t\targ would be 'br1' if br2 is pwd."
    ${ECHO} "\t\t\t\tWC1: /svn/src/br1/d1/d2"
    ${ECHO} "\t\t\t\tWC2: /svn/src/br2/d1/d2"
    ${ECHO} "\t\t\t-d\toutput diff commands"
    ${ECHO} "\t\t\t-v\toutput vimdiff commands"
    ${ECHO} "\t\t\t-p\toutput patch files"
    ${ECHO} "\t\t\t-c\toutput commands to copy files to working copy"
    exit 2
} # end usage()

#
# print banner with stars
#
function msg(){
	local cnt=${#1}
	local sline=''
        local c
	# create line of stars 4 longer than length of first argument to msg
	for ((c=1;c<=(cnt+4);c++)); { sline=${sline}'*'; }
	echo -e "\n\t${sline}\n\t* ${@}\n\t${sline}\n"
} # end msg()

if (($#<2))
then
    usage ${0##*/}
fi

showDifLn=0
showVdfLn=0
crePatch=0
cpFiles=0
cmd0='|less'
cmd1=''
cmd2=''
while getopts :b:dvpc OPT; do
    case $OPT in
        b) br="${OPTARG}";;
        d) showDifLn=1
            cmd0='|grep ^diff'
            cmd1="|awk '{printf(\"%s %s\n\",\$(NF-1),\$NF)}'"
            cmd2='| while read one two; do echo "diff -c ${two} ${one}"; done'
            ;;
        v) showVdfLn=1
            cmd0='|grep ^diff'
            cmd1="|awk '{printf(\"%s %s\n\",\$(NF-1),\$NF)}'"
            cmd2='| while read one two; do echo "vimdiff ${two} ${one}"; done'
            ;;
        p) crePatch=1
            cmd0='|grep ^diff'
            cmd1="|awk '{printf(\"%s %s\n\",\$(NF-1),\$NF)}'"
            cmd2='| while read one two; do echo patch.${two##*/} ;diff -c ${two} ${one} >patch.${two##*/}; done'
            msg "Create Patch files"
            ;;
        c) cpFiles=1
            cmd0='|grep ^diff'
            cmd1="|awk '{printf(\"%s %s\n\",\$(NF-1),\$NF)}'"
            cmd2='| while read one two; do echo cp ${one} ${two} ;done'
            msg "copy files to working copy"
            ;;
        *) usage ${0##*/};;
    esac
done

thisB=$(echo ${PWD%%fmt_0/*}|awk -F"/" '{print $(NF-1)}')
otherPath=$(pwd|sed "s!${thisB}!${br}!")
excludeFile='diffExclude'
ignore="-I '\$URL' -I '\$Id'"
diffOpts='-c -r'
exclOpts='--exclude-from="${HOME}/${excludeFile}"'

eval diff ${diffOpts} ${ignore} ${exclOpts} ${otherPath} . ${cmd0} ${cmd1} ${cmd2}
