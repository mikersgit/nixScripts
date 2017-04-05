#!/bin/bash

# expect first arg to be the name (no slashes) of the file system to replicate
# the second argument should be a double quoted, space delimeted list of the
# segments to filter
# eg. createFilterMnt.sh fs1_4 "1 3 5"
########## 

MODULE=${1}
shift 1
SEGS="${@}"
BIN='/usr/local/ibrix/bin'

HOSTNM=$(hostname)
BASEMNT='/mnt/crr/filter'
FMNT=${BASEMNT}/${MODULE}/${HOSTNM}

mkdir -p ${FMNT}
mount --bind /${MODULE} ${FMNT}
${BIN}/rtool filter ${FMNT} DEFINE ${SEGS}
${BIN}/rtool filter ${FMNT} QUERY

# DELETE
#${BIN}/rtool filter ${FMNT} DELETE
#umount ${FMNT}
#rm -rf ${FMNT}
