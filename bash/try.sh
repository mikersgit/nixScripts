#!/bin/bash
prog=${0##*/}
bprog=${prog%.*}
pdir=${0%/*}
if [[ ${prog} = ${pdir} ]]
then
CONF=${bprog}.conf
else
CONF="${pdir}/${bprog}.conf"
fi
