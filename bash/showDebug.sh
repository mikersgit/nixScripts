#!/bin/bash
#
# script to take the debug flags from ulog.h and compute the logflag mask for
# ibrcfrctl command

#
# flag names
#
declare -a flags=(UTL_QUIET \
*UTL_ERR \
*UTL_WARN \
*UTL_INFO \
UTL_INFO_1 \
UTL_INFO_2 \
UTL_INFO_3 \
UDBG_RPC \
UDBG_AIO \
UDBG_RPL \
UDBG_FS \
*UDBG_KLOG \
*UDBG_LOGIO \
UDBG_RSYNC \
UDBG_LOCK \
UDBG_SERVCTL \
UDBG_CONF \
UDBG_ADM \
UDBG_FLOWCONTROL \
UDBG_CODEFLOW \
*UDBG_MISC)

#
# flag values (in same order as names)
#
declare -a vflags=(0x00000001 \
0x00000002 \
0x00000004 \
0x00000010 \
0x00000020 \
0x00000040 \
0x00000080 \
0x00000100 \
0x00000200 \
0x00000400 \
0x00000800 \
0x00001000 \
0x00002000 \
0x00004000 \
0x00008000 \
0x00010000 \
0x00020000 \
0x00040000 \
0x00080000 \
0x00100000 \
0x00200000 )

#
# display choices
#
for ((i=0;i<${#flags[*]};i++))
{
   echo ${i}  ${flags[${i}]}
}

#
# get selections
#
echo "* flags apply to CRR"
read -p"Space separated list of flags: " f

#
# calculate masks
#
mask=0x0
for i in ${f}
{
  (( mask += ${vflags[$i]} ))
}

#
# convert to hex
hex=$(printf "%x\n" ${mask})
prefix="0x"

#
# pad to 8 chars
#
for ((p=0;p<((8-${#hex}));p++))
{
  prefix=${prefix}"0"
}

echo "mask: ${prefix}${hex}"
