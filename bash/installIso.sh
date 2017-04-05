#!/bin/bash

isoMnt='/mnt/cdrom'
isoNfs='/mnt/isonfs'
FMstopCmd='/etc/init.d/ibrix_fusionmanager stop'
FMstartCmd='/etc/init.d/ibrix_fusionmanager start'
CLupgradeCmd='ibrixupgrade'
CLupgradeOpt='-f'

isoName=${@}
NFS=''

[[ ! -d ${isoMnt} ]] && mkdir -p ${isoMnt}
[[ ! -d ${isoNfs} ]] && mkdir -p ${isoNfs}

while getopts :i:n: OPT; do
    case $OPT in
	i)
	isoName="$OPTARG"
	;;n)
	NFS="$OPTARG"
	;;*)
	echo "usage: ${0##*/} [-i ARG] [-n ARG]"
	exit 2
    esac
done

if grep "${isoMnt}" /proc/mounts
then
        umount -l ${isoMnt}
fi

if ((${#NFS}))
then
    mount ${NFS} ${isoNfs}
    mount -o loop ${isoNfs}/${isoName} ${isoMnt}
else
    mount -o loop ${isoName} ${isoMnt}
fi

if [[ -f ${isoMnt}/${CLupgradeCmd} ]]
then
        cd ${isoMnt}
else
        echo "No upgrade command, ${CLupgradeCmd}, found in ${isoMnt}"
        exit 2
fi

# run likewise init scripts to stop
#
for d in $(rpm -ql $(rpm -qa likewise\*) |grep init.d)
{
	${d} stop
}

# unmount any CRR filter mounts
#
for m in $(mount |grep ibrix |grep filter | awk '{print $3}')
{
	umount ${m}
}

# unmount all ibrix file systems
#
umount -a -t ibrix

./${CLupgradeCmd} ${CLupgradeOpt}

cd
${FMstopCmd}
umount ${isoMnt}
((${#NFS})) && umount ${isoNfs}
${FMstartCmd}
 
