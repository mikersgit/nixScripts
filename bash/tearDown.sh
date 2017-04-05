#!/bin/bash

#
# print banner with stars
#
function msg(){
	local cnt=${#1};local sline='';local c
	# create line of stars 4 longer than length of first argument to msg
	for ((c=1;c<=(cnt+4);c++)); { sline=${sline}'*'; }
	echo -e "\n\t${sline}\n\t* ${@}\n\t${sline}\n"
} # end msg()

msg "Unmount all ibrix FS"

df -t ibrix
FSs=$(df -t ibrix| grep -v ^Filesystem | awk '{printf("%s ",$1)}')

for f in ${FSs}
{
	ibrix_umount -f ${f}
}

msg "Delete and wipe all ibrix FS"

df -t ibrix
# command to completely remove all ibrix file systems, including 
#       logical volumes
#       volume groups
#       physical volumes
#       disk device blocks
###########################


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


msg "Shutdown Ibrix"

for i in $(rpm -ql $(rpm -qa Ibr\* ibr\* \*like\*) |grep init.d)
{
        ${i} stop
}

msg "Remove RPMs"
for r in $(rpm -qa Ibr\* ibr\* \*like\*) 
{
        echo ${r}
        rpm -ev ${r}
}

msg "Remove directories"
# useful to use find to locate
# find . -xdev -type d -name \*ibrix\* -o -name \*likew\*
rm -rf /usr/local/ibrix &
rm -rf /var/log/cfr &
rm -rf /var/lib/ibrix &
rm -rf /etc/ibrix &
rm -rf /local/ibrix* &
rm -rf /opt/likewise &
rm -rf /etc/likewise &
rm -rf /var/likewise* &
rm -rf /var/lib/likewise &
rm -rf /var/log/likewise* &

wait

pgrep -l ibr
pvs
lvs
vgs

msg "Deleting any remaining ibrix volume groups"
for i in ${VGs}
{
        vgremove -f ${i}
}

msg "Wiping data from ibrix disk devs"
for d in ${lPVs}
{
        echo -e "\tWipe ${d}"
        dd if=/dev/zero of=${d} bs=4096 count=1000
}
msg "remove ibrix user and groups"
grps="$(groups ibrix  | awk -F ":" '{print $2}')"
userdel -r ibrix
for g in ${grps}
{
        groupdel ${g}
}

msg "Is ibrix kernel module still listed? (rmmod ibrix to remove)"
lsmod |grep -i ibr

msg "May need to modify /etc/hosts to remove AD domain from hosts"
