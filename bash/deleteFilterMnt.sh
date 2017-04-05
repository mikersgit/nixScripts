#!/bin/bash

# expect first arg to be the name (no slashes) of the file system that was
# replicated.
# eg. deleteFilterMnt.sh fs1_4 
########## 

MODULE=${1}
BIN='/usr/local/ibrix/bin'

HOSTNM=$(hostname)
BASEMNT='/mnt/crr/filter'
MODMNT=${BASEMNT}/${MODULE}
FMNT=${BASEMNT}/${MODULE}/${HOSTNM}

# DELETE
${BIN}/rtool filter ${FMNT} DELETE
umount ${FMNT}
rm -rf ${MODMNT}
