#!/bin/bash

#
# remove file system completely
#

if (( ${#} < 1 ))
then
    echo "Must supply a file system name like:"
    ibrix_fs -l | tail --lines=+3 | awk '{print $1}'
    exit 1
fi

FS="${1}"
declare -a hst=($(ibrix_fm -f | tail --lines=+3 | awk '{f=f" "$1};END {print f}'))

# print banner with stars
function msg(){
	local cnt=${#1};local sline='';local c
	# create line of stars 4 longer than length of first argument to msg
	for ((c=1;c<=(cnt+4);c++)); { sline=${sline}'*'; }
	echo -e "\n\t${sline}\n\t* ${@}\n\t${sline}\n"
} # end msg()

msg "Check if the file system is busy"
lsof |grep ${FS}
rc=$?
if (( ! rc ))
then
    echo "You must make ${FS} not busy before deleting it."
    exit 1
fi
msg "remove cifs shares"
ibrix_cifs -d -f ${FS}
ibrix_cifs -i

msg "remove nfs exports"
ibrix_exportfs -l > t
cat t

for h in ${hst[*]}
{
    ibrix_exportfs -U -h ${h} -p *:/${FS}
}

ibrix_lv -l |grep ${FS} > t

declare -a lv=($(awk '{print $1}' t))
declare -a vg=($(awk '{print $NF}' t))
ibrix_pv -l > t
i=0
for v in ${vg[*]}
{
     pv[${i}]=$(awk '$NF ~ /^'${v}'$/ {print $1}' t)
     dev[${i}]=$(vgdisplay -v ${v} 2>/dev/null|grep 'PV Name'|awk '{print $NF}')
     ((i+=1))
}

msg "unmount"
ibrix_umount -f ${FS}

msg "delete"
ibrix_fs -d -f ${FS}

msg "delete lvs, vgs, pvs associated"
for (( i=0;i<${#lv[*]};i++ ))
{
    ibrix_lv -d -s ${lv[${i}]}
}

for (( i=0;i<${#vg[*]};i++ ))
{
    ibrix_vg -d -g  ${vg[${i}]}
}

for (( i=0;i<${#lv[*]};i++ ))
{
    ibrix_pv -d -p ${pv[${i}]}
}

msg "Zero out sd devices"
for (( i=0;i<${#dev[*]};i++ ))
{
  dd if=/dev/zero of=${dev} bs=4096 count=1000
}

msg "Discover zero'd devices"
ibrix_pv -a
ibrix_pv -l
