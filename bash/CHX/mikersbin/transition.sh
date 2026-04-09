#!/bin/bash
set -x
IFdir=/etc/network
IFfile=${IFdir}/interfaces
CurrConf=/home/exodus/.config/etc/network/current.conf

#
# check for either eth0 or en0
IFzero=$(ls -1 /sys/class/net/ |awk '{if ($1 ~ "eth0|en0" ) print }')

IFe0=${IFdir}/interfaces.d/$IFzero.conf

if grep -E '^[[:blank:]]*[^#].*'$IFzero ${IFfile}
then
        sed  '/allow/,/source/{/source/!d}' ${IFfile} > ${IFfile}.new
        sed -n '/allow/,/source/{/source/!p}' ${IFfile} > ${IFe0}
        mv ${IFfile}.new ${IFfile}
        cp ${CurrConf} ${CurrConf}.$(date '+%y%j')
        cp ${IFfile} ${CurrConf}
        #rc-update del networking sysinit
        #rc-update add networking.chx sysinit
fi
