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
declare -a ops_vals=( JOB_SELF_SCAN=0x1 \
   JOB_FRESH_START=0x2 \      
   JOB_ENABLE_SPMNTPNT=0x4 \      
   JOB_AUTO_SELF_SCAN=0x8 \      
   JOB_PRESERVE_LOG=0x10 \     
   JOB_RSYNC_DEBUG=0x20 \     
   JOB_AUTOPROBE=0x40 \     
   JOB_AGGRESSIVE=0x80 \     
   JOB_USE_SIGNIANT=0x100 \    
   JOB_USE_COMPRESS=0x1000 \    
   JOB_USE_DELTA=0x2000 \    
   JOB_DEL_DEST=0x4000 \    
   JOB_USE_INPLACE=0x8000 \    
   JOB_ENABLE_HLINK=0x10000 \    
   JOB_SET_BW=0x20000 \    
   JOB_PAUSED_INITIALLY=0x40000 \    
   JOB_REMOVE_STOPPED=0x01000000 \    
   JOB_STOP_ALL=0x02000000 )   

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

