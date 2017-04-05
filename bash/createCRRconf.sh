#!/bin/bash

# create ibrcfrworkerd.conf file on TARGET node
# run this on each target node that will be participating
# in sync
# eg. createCRRconf.sh fs2_f4 fs1_40
#
SRCFS=${1}
TARGFS=${2}
CONF='/etc/ibrix/engine/ibrcfrworkerd.conf'
SECFL='/etc/ibrix/engine/ibrcfrworkerd.secrets.'${TARGFS}

cat >> ${CONF} << EOC
[${SRCFS}]
uid = 0
gid = 0
auth users = root
strict modes = false
log file = /usr/local/ibrix/log/ibrcfrworkerd.log
path = /${TARGFS}
read only = false
secrets file = ${SECFL}
EOC
echo 'root:hpinvent
ibrcfr:whatalife' >> ${SECFL}
chmod 644 ${SECFL} ${CONF}
