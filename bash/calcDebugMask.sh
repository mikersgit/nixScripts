#!/bin/bash
#
# script to take the debug flags from ulog.h and compute the logflag mask for
# ibrcfrctl command

#
# flag names and values
#
declare -a flags_values=(UTL_QUIET=0x00000001 \
*UTL_ERR=0x00000002 \
*UTL_WARN=0x00000004 \
*UTL_INFO=0x00000010 \
UTL_INFO_1=0x00000020 \
UTL_INFO_2=0x00000040 \
UTL_INFO_3=0x00000080 \
UDBG_RPC=0x00000100 \
UDBG_AIO=0x00000200 \
UDBG_RPL=0x00000400 \
UDBG_FS=0x00000800 \
*UDBG_KLOG=0x00001000 \
*UDBG_LOGIO=0x00002000 \
UDBG_RSYNC=0x00004000 \
UDBG_LOCK=0x00008000 \
UDBG_SERVCTL=0x00010000 \
UDBG_CONF=0x00020000 \
UDBG_ADM=0x00040000 \
UDBG_FLOWCONTROL=0x00080000 \
UDBG_CODEFLOW=0x00100000 \
*UDBG_MISC=0x00200000 )

# put flag names, and values in separate, but identically indexed
# arrays
#
j=0
for o in ${flags_values[*]}
{
   flags[$j]=${o%=*}
   vflags[$j]=${o#*=}
   ((j++))
}

#
# display choices
#
echo -e "#\tName\t\t #\tName"
echo "============================================="
for ((i=0;i<${#flags[*]};i++))
{
   echo -e "${i}\t${flags[${i}]}\c"

   sz=${#flags[${i}]}
   spc='\t '
   if (( sz < 8  ))
   then
       spc='\t\t '
   elif (( sz >= 16 ))
     then
       spc=' '
   fi
   (( i++ ))
   (( i <${#flags[*]} )) && echo -e "${spc}${i}\t${flags[${i}]}"
}

#
# get selections
#
echo -e "\n* flags apply to CRR"
read -p"Space separated list of flags (e.g. 1 2 4): " f

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
