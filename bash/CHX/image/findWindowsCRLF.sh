#!/bin/bash

##########################
# ChampionX 2022
#
# Search the top level directories for files that have Windows style CRLF.
# These can cause havoc, especially in /etc startup scripts.
# Skip file with extensions where the style of EOL is of now consequence.
# This is primarily for creating SD card, and SystemUpdate images for Smarten product releases.
#
###########

if [ ${#} -lt 1 ]
then
   echo "USAGE: ${0} /base/dir, example: ${0} /mnt/img <== find the files"
   echo "       ${0} -F fixFileList, example: ${0} -F /tmp/tmp.zTPWLseIU2 <== fix the files"
   exit 1
fi

#
# defaults
#
doFix=0
doFind=1

#
# Is this a find or fix request
#
if [ ${#} -gt 1 ]
then
   doFix=1
   doFind=0
   shift 1
   TMPFILE=${1}
else
   anchorDir=${1}
   TMPFILE=$(mktemp)
fi

#
# for each top level path use find to locate files that have windows style EOL, skipping file extensions
# that are not affected by having this style.
# Each top level 'find' is launched in the background with high priority so the searches can be done in
# parallel. A 'wait' is in place for these background processes.
#########################
function doFindFunc() {
    for DPATH in ${dirs}
    do
         fullPath=${anchorDir}/${DPATH}
         if [ -e ${fullPath} ]
         then
             echo -e "\t=========== ${fullPath} ==========="
             nice -n -10 find ${fullPath} -type f \( ! -path \*node_module\* ! -path \*tabset\* \) \( ! -name \*dat ! -name \*ini ! -name \*html ! -name \*hex ! -name \*csv ! -name \*js ! -name \*json ! -name \*img ! -name \*sql ! -name \*xml ! -name \*css  \) -exec grep -le '$' {} \; 2>/dev/null |  xargs file |  grep CRLF |  grep -v -e XML -e Perl >> ${TMPFILE} &
         else
                echo "${DPATH} not found"
         fi
    done
    wait
    echo -e "\n\t=========== ${TMPFILE} ==========="
    cat ${TMPFILE}
} # end doFindFunc()

#
# if in 'find' mode set the dirs to search
#####################
function setDirs() {
dirs="bin
boot
data
etc
home
lib
opt
sbin
usr
var"
} #end setDirs()

if [ ${doFind} -eq 1 ]
then
    echo "=========== This takes approximately 4 minutes ======="
    setDirs
    doFindFunc 
fi

exec 7<${TMPFILE}
while read -u 7 fxfile jnk
do
   ls -l ${fxfile%:}
   if [ ${doFix} -eq 1 ]
   then
       sed -i 's/$//' ${fxfile%:}
   fi
done
exec 7<&-

if [ ${doFind} -eq 1 ]
then
   lns=$(wc -l ${TMPFILE}|awk '{print $1}')
   echo -e "\nEdit the file ${TMPFILE} to remove items that do not need to have CRLF removed."
   echo "${lns} lines in the fix file"
   echo "Then the file can be used as input to fix the files"
   echo "       ${0} -F ${TMPFILE}"
fi
