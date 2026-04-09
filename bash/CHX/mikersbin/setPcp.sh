#!/bin/bash
###########
## ----------------------------------------------------------------------------------------------------------
##  Copyright 2023, ChampionX
##
##  ChampionX CONFIDENTIAL AND PROPRIETARY
##  This software is an unpublished work and contains valuable trade secrets that are confidential and
##  proprietary to ChampionX, and may only be disclosed to individuals who have entered into a
##  confidentiality agreement with
##  ChampionX, and may not be copied or reproduced in whole or in part.

EXHOME="/home/exodus"
DB="${EXHOME}/Databases/Genesis/genesis-config.sqlite"
SQL=/usr/bin/sqlite3
TABLE=SystemConfig
KEY='222222'
ENABLE='1'
PcpLicF="PcpLicenseKey"
PcpEnaF="PcpEnabled"

# PcpLicenseKey|PcpEnabled
function setMode() {
        ${SQL} ${DB} "update ${TABLE} set ${PcpLicF}=${KEY};"
        ${SQL} ${DB} "update ${TABLE} set ${PcpEnaF}=${ENABLE};"
}

function listMode() {
        echo "Table: ${TABLE}"
        echo -e "${PcpLicF} \c"
        ${SQL}  ${DB} "select ${PcpLicF} from ${TABLE} ;"
        echo -e "${PcpEnaF} \c"
        ${SQL}  ${DB} "select ${PcpEnaF} from ${TABLE} ;"
}

listMode
if [ ${#1} -gt 0 ]
then
        echo "setMode"
        setMode
        echo "listMode"
        listMode
else
		echo "To change the Pcp License key use:"
		echo -e "\t${0} set"
fi
