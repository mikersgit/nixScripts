#!/bin/bash

# command to completely remove all ibrix file systems, including 
#       logical volumes
#       volume groups
#       physical volumes
#       disk device blocks
###########################

function msg() {
       local BRDR='\t###########################\n'
        echo -e "${BRDR}\t# ${@}\n${BRDR}"
}

msg "mounted ibrix file systems"
df -t ibrix
FSs=$(df -t ibrix| grep -v ^Filesystem | awk '{printf("%s ",$1)}')

for f in ${FSs}
{
	ibrix_umount -f ${f}
}

# FSs="${@}" ## could use this if we wanted to specify fewer than all
ibrix_fs -l

# if (( ${#} ==  0 ))
# then
	msg "Deleting all ibrix file systems"
	FSs=$(ibrix_fs -l | grep -v -e ^FS_NAME -e ^---- | awk '{printf("%s ",$1)}')
# else
	# msg "Deleting ${FSs}"
# fi	

for f in ${FSs}
{
        echo -e "\tDelete file system ${f}"
	ibrix_fs -d -f ${f}
}

LVs=$(ibrix_lv -l |  grep -v -e ^LV_NAME -e ^---- | awk '{printf("%s ",$1)}')
VGs=$(ibrix_vg -l |  grep -v -e ^VG_NAME -e ^---- | awk '{printf("%s ",$1)}')
PVs=$(ibrix_pv -l |  grep -v -e ^PV_NAME -e ^---- | awk '{printf("%s ",$1)}')

msg "Deleting all ibrix logical volumes"
for l in ${LVs}
{
        echo -e "\tDelete logical volume ${l}"
	ibrix_lv -d -s ${l}
}

msg "Deleting all ibrix volume groups"
for v in ${VGs}
{
        echo -e "\tDelete volume group ${v}"
	ibrix_vg -d -g ${v}
}

msg "Deleting all ibrix physical volumes"
for p in ${PVs}
{
        echo -e "\tDelete physical volume ${p}"
	ibrix_pv -d -p ${p}
}

lPVs=$(pvs | awk '{if (NF == 5) printf("%s ",$1)}')

msg "Wiping data from ibrix disk devs"
for d in ${lPVs}
{
        echo -e "\tWipe ${d}"
        dd if=/dev/zero of=${d} bs=4096 count=1000
}
