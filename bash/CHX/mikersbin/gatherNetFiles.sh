#!/bin/bash
MSG="${1}"
EHOME=/home/exodus
OUT=${EHOME}/netfiles.txt

NFILES=(interfaces interfaces.d/eth0.conf interfaces.d/eth1.conf)
NDIR=/etc/network
CNDIR=${EHOME}/.config${NDIR}
{
echo -e "========================================"
echo -e "=========== $(date) ========="
echo -e "============ ${MSG} ==================="
for f in ${NFILES[*]}
{
  echo "======== ${NDIR}/$f ========"
  cat ${NDIR}/$f
  echo "======== ${CNDIR}/$f ========"
  cat ${CNDIR}/$f
}
echo -e "======== End Files ========\n"
echo -e "======== running network ========\n"
ip addr sh
ip r
echo -e "======== rc sysinit status ========\n"
rc-status sysinit |grep network
echo -e "============================="
echo -e "======== End ========"
echo -e "============ ${MSG} ==================="
} >> ${OUT}
