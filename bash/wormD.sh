#!/bin/bash

SBIN='/usr/local/ibrix/sbin'
BIN='/usr/local/ibrix/bin'
retenAdmin=${SBIN}/ibr_reten_adm
FMretenAdmin=${BIN}/ibrix_reten_adm
showReten=${SBIN}/showreten

FMfs=${BIN}/ibrix_fs

# get stat info
stat --printf "%n\t%i\t%F\trefCnt: %h\natime:%x\tmtime:%y\tctime:%z\n" ${files}

# show file system attrs
${showReten} -p ${files}

# show FM archive fs attrs
${FMfs} -W -f ${fs}

# show file attrs
${showReten} ${files}

# set retained time ( must be done before setting archived)
touch -a -d "1 hour" ${files}
#touch -a -d "60 day" ${files}

# set archived
chmod 444 ${files}
