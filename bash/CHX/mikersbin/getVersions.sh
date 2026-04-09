#!/bin/bash
###########
## ----------------------------------------------------------------------------------------------------------------------
##  Copyright 2024, ChampionX
##
##  ChampionX CONFIDENTIAL AND PROPRIETARY
##  This software is an unpublished work and contains valuable trade secrets that are confidential and proprietary to
##  ChampionX, and may only be disclosed to individuals who have entered into a confidentiality agreement with
##  ChampionX, and may not be copied or reproduced in whole or in part.
#
# Called by smarten_update.sh and dpkg_update.sh to update the info in /etc/dogtag 
#
if [[ $# -ge 1 ]];then
	EHM=${1}
else
	EHM=/home/exodus
fi
### Objects to query for versions
#################################
GENDLL=${EHM}/Engine/GenesisMcp.dll
EXODUSLIB=${EHM}/lib/libRIB2.so.1.0
SMARTENPKG="smarten-system"

### Kernel version, build, architecture
#######################################
KERNVER="$(uname -r)"
KERNBLD="$(uname -v)"
KERNARCH="$(uname -m)"

# Extract GenesisMCP build version
GENMCP="$(strings -el ${GENDLL} |
 awk '{if ($1 == "Assembly") {
         printf "%s ", $0
         if (getline > 0 ) {
                 print
         }
 }}')"
# Extract GenesisMCP build date
GENMCPDATE="$(strings ${GENDLL}| grep "\/202[3456789]")"

# Build array with libRIB2 version, date, and source strings
LIBRIB2ARY=($(strings ${EXODUSLIB}|grep "[[:space:]]V[4-9]" |awk '{for (i=3;i<=NF;i++) {printf "%s ", $i}  printf "\n"}'))

# If there is a smarten-system package installed, build array of version and description information
# otherwise skip
# expected format "<install state> <package name> <package version> <package description>"
SMARTENDEB=""
if dpkg -l ${SMARTENPKG} >/dev/null 2>&1
then
   SMARTENDEB=($(dpkg -l ${SMARTENPKG} |awk '/^ii/ {printf "%s %s ", $2,$3;for (i=5;i<=NF;i++) {printf "%s ",$i} printf "\n"}'))
fi

echo "============ Versions ============"
echo "Kernel version: ${KERNVER}; Build date: ${KERNBLD}; Platform: ${KERNARCH}"
echo "GenesisMCP: ${GENMCP}; Build date: ${GENMCPDATE}"
echo "libRIB2 version: ${LIBRIB2ARY[*]}"
# If smarten-system package information was found, echo it out
if [ ${#SMARTENDEB} -gt 1 ]
then
        for i in $(seq 3 ${#SMARTENDEB[*]})
        do
                SMARTENDESC="${SMARTENDESC} ${SMARTENDEB[${i}]}"
        done
        echo "Smarten System: ${SMARTENDEB[0]} ${SMARTENDEB[1]} ${SMARTENDESC}"
fi
