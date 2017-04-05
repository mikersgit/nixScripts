#!/bin/bash

# script to move specified ISO to cluster machines (scp or NFS), and then
# install the ISO starting with the Fusion manager
function usage() {

	echo -e "usage:\t${1##*/} -f FusionMgr -s \"quoted SS list\" [-k] [-N $(hostname -i):/var/iso] [-?h] ISO"
	echo -e "\t-f FusionMgr(s)  Single IP address or quoted space separated list"
	echo -e "\t-s Seg Server(s) Single IP address or quoted space separated list"
	echo -e "\t-k               Setup ssh-keys to FM and SS before sending ISO"
	echo -e "\t-F               Clean-up from previous invocations of sendIso"
	echo -e "\t-N               NFS exported location (IP:directory)"
	echo -e "\t-[?h]            This message"
	exit 2
}

(( $# < 2 )) && usage ${0}

keys=0 # flag to distribute keys first, default is not to
freshStart=0
useNFS=0

while getopts :Ff:s:N:k?h OPT; do
    case $OPT in
	f)
	FM="$OPTARG"
	;;s)
	SS="$OPTARG"
	;;k)
	keys=1
	;;F)
	freshStart=1
	;;N)
        NFSdir="${OPTARG}"
	useNFS=1
	;;*)
	usage ${0}
    esac
done
shift $[ OPTIND - 1 ]
ISO=${@}

if (( ${#ISO} < 1 ))
then
	echo "Please provide an ISO image as the last argument on command line."
	exit 1
fi

#
# make sure NFS is running and re-export /etc/exports contents
#
# /etc/exports should be something like:
# /var/iso *(sync,rw,insecure,no_root_squash)
#
function checkNFS() {

        local dir=${NFSdir#*:}
        local expOpts='*(sync,rw,insecure,no_root_squash)'
        local expFile='/etc/exports'

        [[ ! -d ${dir} ]] && mkdir -p ${dir}

        if ! grep ^${dir} ${expFile} 2>&1 > /dev/null
        then
                echo -e "${dir}\t ${expOpts}" >> ${expFile}
        fi

        /etc/init.d/nfs status 2>&1 >/dev/null
        rc=$?
        if (( rc > 0 ))
        then
                /etc/init.d/nfs restart
        fi
        /usr/sbin/exportfs -av
} # end checkNFS()

#
# make sure all IPs unique and reachable
#
function checkMachines() {

 tfl=$(mktemp)

 for i in ${FM} ${SS}
 {
	echo ${i}  >> ${tfl}
 }

 c=$(wc -l ${tfl}| awk '{print $1}')
 uc=$(sort -u ${tfl}|wc -l| awk '{print $1}')

 if (( c != uc ))
 then
	echo "Only specify each IP address once. If an IP is in the 'F' list it"
	echo "Cannot be in the 'S' list, and the converse."
	exit 1
 fi
 rm -f ${tfl}
} # end checkMachines()

#
# make sure all IPs unique and reachable
#
checkMachines

remoteInstProg='/root/installIso.sh'
localInstProg='/root/bin/installIso.sh'

function distrib_keys() {
   keyList="$(ls ~/.ssh/id_*.pub)"
   local=$(hostname)
   for h in ${@}
   {
      for k in ${keyList}
      {
         scp ${k} ${h}:.ssh/${local}${k##*/}
         ssh ${h} "cat .ssh/${local}${k##*/} >> .ssh/authorized_keys2"
      }
   } 
}

#
# here doc to create install script that is copied to and run on remote
# machines
#
function create_installsh() {
cat << 'EOF'
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
 
EOF
}

if ((keys))
then
   distrib_keys ${FM} ${SS}
fi

# always re-create install prog, cheap and fast, no reason not to
rm -f ${localInstProg}
create_installsh > ${localInstProg}
chmod +x  ${localInstProg}

# test for installIso on machines, if not there, make sure have a local copy
# and then copy it over
#
for i in ${FM} ${SS}
{

        # always re-copy install prog, cheap and fast, no reason not to
    	ssh ${i} "rm -f ${remoteInstProg}"
        scp -p ${localInstProg} ${i}:${remoteInstProg}

}

#
# Depending on selected mode either setup for NFS mounting
# or scp ISO to remote machine
#
function transIso() {
        local TransISO=${1}    # local ISO to copy
        local transDest=${2}   # IP address
        local dir=${NFSdir#*:} # exported NFS directory
        if (( useNFS ))
        then
                checkNFS
                if [[ ! -f ${dir}/${TransISO##*/} ]]
                then
                        echo "copy ${TransISO} to  ${dir}"
                        /bin/cp ${TransISO} ${dir}
                else
                        cksm1=$(cksum ${dir}/${TransISO##*/} |awk '{print $1}')
                        cksm2=$(cksum ${TransISO} |awk '{print $1}')
                        if (( cksm1 != cksm2 ))
                        then
                                echo "(${cksm1} ${cksm2}) replace ${TransISO} in  ${dir}"
                                /bin/cp -f ${TransISO} ${dir}
                        fi
                fi
                NFScmd="-n ${NFSdir}"
        else
                scp  ${TransISO} ${transDest}:.
                NFScmd=" "
        fi
} # end transIso()

line='################'
pline='## '
mtype="${pline}FM: " # machine type
# start with fusion manager. may be more than one if more than one cluster
for i in ${FM}
{
  phase="${pline}START"
  echo -e "\n${line}\n${phase}\n${mtype}${i}\n${line}"
  ((freshStart)) && ssh ${i} "rm -f ibrix-*iso"
  transIso  ${ISO} ${i}
  ssh ${i} "${remoteInstProg} -i ${ISO##*/} ${NFScmd}"
  phase="${pline}END"
  echo -e "\n${line}\n${phase}\n${mtype}${i}\n${line}"
}

mtype='SS: ' # machine type
# now do segment servers
for i in ${SS}
{
  phase="${pline}START"
  echo -e "\n${line}\n${phase}\n${mtype}${i}\n${line}"
  ((freshStart)) && ssh ${i} "rm -f ibrix-*iso"
  transIso  ${ISO} ${i}
  ssh ${i} "${remoteInstProg} -i ${ISO##*/} ${NFScmd}"
  phase="${pline}END"
  echo -e "\n${line}\n${phase}\n${mtype}${i}\n${line}"
}

exit $?
