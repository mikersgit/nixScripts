#!/bin/bash
#
# decode IBR operation bits from include/ibrix_common.h
#

if (( ${#} < 1 ))
then
  echo "usage: ${0##*/} HexNumber"
  exit 1
fi

# input value to decode
#
in=${1}

# prepend '0x' if needed
[[ ${in} != 0x* ]] && in="0x${in}"

# array of ops and values
#
declare -a ops_vals=( IBR_BIT_CFR=0x00100000 \
   IBR_BIT_NOP=0x0 \      
   IBR_BIT_CREATE=0x1 \      
   IBR_BIT_MKDIR=0x2 \      
   IBR_BIT_MKNOD=0x4 \      
   IBR_BIT_TRUNCATE=0x8 \      
   IBR_BIT_RMDIR=0x10 \     
   IBR_BIT_LINK=0x20 \     
   IBR_BIT_SYMLINK=0x40 \     
   IBR_BIT_RENAME=0x80 \     
   IBR_BIT_SETATTR=0x100 \    
   IBR_BIT_SETXATTR=0x200 \    
   IBR_BIT_REMOVEXATTR=0x400 \    
   IBR_BIT_WRITE=0x800 \    
   IBR_BIT_UNLINK=0x1000 \   
   IBR_BIT_RSYNC=0x2000 )

# put operation names, and values in separate, but identically indexed
# arrays
#
j=0
for o in ${ops_vals[*]}
{
   ops[$j]=${o%=*}
   vals[$j]=${o#*=}
   ((j++))
}

echo "Operations indicated by ${in}"

# for each bit value AND with input and indicate if there is a match,
# and the name of the operation
#
for ((i=0;i<${#vals[*]};i++))
{
    (( in & ${vals[$i]})) && printf "%s\n" ${ops[$i]}
}

