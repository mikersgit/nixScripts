#!/bin/bash

#
# script to update or fresh install a VM couplet deployed from labman.
# expects to be run the node that is to become the active FM, also expects that
# a copy of this script exists on the passive node.
#

function get_node() {
(( DEBUG )) &&  set -x
   if (( node != 1 && node != 2 ))
   then
      echo "Node is: ${node}"
      echo "Specify if this is the first node [1], or second node [2] to be"
      echo "upgraded in this cluster"
      read -p"Node: " node
   fi
   if (( node > 2 ))
   then
	echo "node number can only be '1' or '2'"
	exit 1
   fi
} # end get_node()

#
# pull ibrix version info from the IbrixCommon rpm. If greater than 6.0.250, use new syntax
# If new version then NEW=1; else NEW=0
#
function ibr_init_ver() {
        local RPMPATH='distrib/IBRIX/RHEL5/x86_64'
        local RPMNAME='IbrixCommon'
        (( DEBUG )) && set -x
        NEW=$(rpm -qi --qf "VER==%-10{VERSION}\n" -p /mnt/cdrom/${RPMPATH}/${RPMNAME}*.rpm |
        awk '$1 ~/VER==/ {sub("=="," ");split($NF,a,".");if (a[1]>5) print "1";else print "0"}')
}

function setupRemove() {
(( DEBUG )) && set -x
   [[ -f /etc/init.d/ibrix_server ]] && /etc/init.d/ibrix_server stop
   [[ -f /etc/init.d/ibrix_fusionmanager ]] && /etc/init.d/ibrix_fusionmanager stop

   #
   # kill all the likewise daemons
   #
   [[ -f /etc/init.d/lwsmd ]] && /etc/init.d/lwsmd stop

   #
   # second bullet just to be sure
   #
   pkill -KILL lw[s,r,i].*d
   
   #
   # get ISO
   #
   mkdir -p /var/iso
   mkdir -p /mnt/nfs
   mkdir -p /mnt/cdrom

   path=''
   if (( nfs ))
   then

       # if NFS not running, start it 
       if ! pgrep nfs > /dev/null
       then
            /etc/init.d/nfs start  
       fi

       mount ${location} /mnt/nfs
       path='/mnt/nfs/'
   fi

   mount -o loop ${path}${ISO} /mnt/cdrom

   #
   # get to the directory with the mounted ISO
   #
   cd /mnt/cdrom

   #
   # remove old install
   #
   if [[ -f /mnt/cdrom/ibrixinit ]]
   then
      ibr_init_ver
        (( DEBUG )) && echo "NEW is ${NEW}"
      if [[ -f /usr/local/ibrix/sbin/uninstallfm ]]
      then
        (( DEBUG )) && echo "NEW is ${NEW}"
        if (( $NEW == 1 ))
        then
         /mnt/cdrom/ibrixinit -u
        else
         /mnt/cdrom/ibrixinit -ts -u
         /mnt/cdrom/ibrixinit -tm -u
        fi
      fi
   else
      echo "ibrixinit command not found. is ISO mounted at /mnt/cdrom"
      exit 1
   fi

   rm -rf /usr/local/ibrix /etc/ibrix

   #
   # verify ibrix rpm's are gone
   #
   rpm -e $(rpm -qa Ibrix\* ibrix\* ibrcfr\*)

   #
   # remove likewise rpm
   #
   rpm -e $(rpm -qa like*)
   rm -rf /opt/likewise /etc/likewise /var/lib/likewise

} # end setupRemove()

function install_ibr() {
(( DEBUG )) && set -x

        # Determine if the NEW or OLD ibrixinit syntax is needed
        ibr_init_ver
        (( DEBUG )) && echo "NEW is ${NEW}"
        if (( NEW ))
        then
                AINITOPTS=' '
                PINITOPTS=' '
        else
                AINITOPTS='-tm -M active'
                PINITOPTS='-tm -M passive'
        fi

#
# get unique info for virtual IP setup and clusnter name
#
(( ${#userVIP} < 1 )) && read -p"IP for user VIP: " userVIP
(( ${#cname} < 1 )) && read -p"Cluster name NOT same as hostname: " cname

if (( node == 1 ))
then
   #
   # on first node, and active FM, install FM first then segment server
   #
   /mnt/cdrom/ibrixinit ${AINITOPTS} -C ${mgmntNIC} \
                        -v ${mgmntVIP} -m 255.255.0.0 -d ${mgmntNIC}:1 \
                        -w 9009 -F \
                        -V ${userVIP} -D ${userNIC}:1 -N 255.255.255.0 \
                        -c ${cname}
   ip addr
   /etc/init.d/ibrix_fusionmanager status
   /usr/local/ibrix/bin/ibrix_fm -i
   /usr/local/ibrix/bin/ibrix_fm_tune -l
   read -t 5 -p"Continue with install of segmnet server [y]/n? " ans
   if [[ ${ans} = [Nn] ]]
   then
	echo "Exiting install"
	exit 1
   fi
   # do not run FSN install if new syntax called for
   echo
        (( DEBUG )) && echo "NEW is ${NEW}"
   (( ! NEW )) && /mnt/cdrom/ibrixinit -ts -C ${userNIC} -i ${userVIP} -F
else
   #
   # on second node, and passive FM, install segment server first then FM 
   #
        (( DEBUG )) && echo "NEW is ${NEW}"
   (( ! NEW )) && /mnt/cdrom/ibrixinit -ts -C ${mgmntNIC} -i ${mgmntVIP} -F
   /mnt/cdrom/ibrixinit ${PINITOPTS} -C ${mgmntNIC} \
                        -v ${mgmntVIP} -m 255.255.0.0 -d ${mgmntNIC}:1 \
                        -w 9009 -F \
                        -V ${userVIP} -D ${userNIC}:1 -N 255.255.255.0 \
                        -c ${cname}
fi
} # end install()

function umount_iso() {
   fstype=${1}
   mntPt=${2}
   if df -t ${fstype} |grep ${mntPt} 2>&1 >/dev/null
   then
      umount ${mntPt}
   fi
} # end umount_iso()

function usage() {
	local p=${1##*/}
        echo -e "usage:\t${p} -n nodeNumber -U userNIC -u userVIP -N clusterName -C mgmntNIC -c mgmntVIP -I ISOname [-L nfsLocation] [-s otherSegServerIP] [-r?h] "
        echo -e "\t-n nodeNumber  '1' if this is the first node to be upgraded, '2' otherwise"
        echo -e "\t-s otherSegServerIP IP address of the passive, or node 2 segserver"
        echo -e "\t-U userNIC (eg. eth1) Interface associated with user VIP"
        echo -e "\t-u userVIP user virtual IP address of the fusion manager"
        echo -e "\t-C managementNIC (eg. eth0) Interface associated with mgmnt server VIP"
        echo -e "\t-c managementVIP management server virtual IP address of the fusion manager"
        echo -e "\t-N clusterName The name of the cluster used by fusion manager NOT hostname"
        echo -e "\t-I ISOname The name the ISO to mount. put full path if it is locally available"
        echo -e "\t   or just the file name if it is going to be NFS mounted"
        echo -e "\t-L nfsLocation enter the IP and the directory like 1.1.1.1:/var/exported"
        echo -e "\t-r             remove software then exit"
        echo -e "\t-[?h]            This message"
        echo -e "EXAMPLE\n"
	echo "${p} -n 1 -U eth1 -u 172.27.1.42 -N mwr2_cl -C eth0 -c 10.30.252.42 -I /var/iso/ibrix-pkgfull-FS_6.0.117+IAS_6.0.116-x86_64.iso"
echo "# ibrix_nic -l
HOST                           IFNAME  TYPE     STATE       IP_ADDRESS    MAC_ADDRESS        BACKUP_HOST  BACKUP_IF  ROUTE  LINKMON
-----------------------------  ------  -------  ----------  ------------  -----------------  -----------  ---------  -----  -------
mwr2lmvm1                      eth1    Cluster  Up, LinkUp  172.27.1.1    00:50:56:3a:07:60                                 No
mwr2lmvm1 [Active FM Nonedit]  eth0:1  Cluster  Up, LinkUp  10.30.252.42                                                    No
mwr2lmvm1 [Active FM Nonedit]  eth1:1  User     Up, LinkUp  172.27.1.42                                                     No
"
        exit 2
}

node=0
remove_only=0
userVIP=''
cname=''
localIso=1
nfs=0

while getopts :n:s:u:U:c:C:N:I:L:r?h OPT; do
    case $OPT in
        n|+n)
        node="$OPTARG"
        ;;s|+s)
        SS="$OPTARG"
        ;;u|+u)
        userVIP="$OPTARG"
        ;;U|+U)
        userNIC="$OPTARG"
        ;;c|+c)
        mgmntVIP="$OPTARG"
        ;;C|+C)
        mgmntNIC="$OPTARG"
        ;;N|+N)
        cname="$OPTARG"
        ;;I|+I)
        ISO="$OPTARG"
        ;;L|+L)
        location="$OPTARG"
	localIso=0
	nfs=1
        ;;r|+r)
        remove_only=1
        ;;*)
        usage ${0}
    esac
done
shift $[ OPTIND - 1 ]

get_node ${1}

#
# if there is another node specified take its server down too
#
if (( ${#SS} > 1 ))
then
	read -p"location of ${0##*/} on ${SS}" sLOC
	ssh -t ${SS} "bash ${sLOC} -n2 -u ${userVIP} -c ${cname} -I ${ISO} -L ${location} -r"
fi

setupRemove

if (( ! remove_only ))
then
   install_ibr # local 'active' install

   # remove 'passive' install
   if (( ${#SS} > 1 ))
   then
	ssh -t ${SS} "bash ${sLOC} -n2 -u ${userVIP} -c ${cname} -I ${ISO} -L ${location}"
   fi
fi

cd /

# stop ibrix to free up mount point
#
   [[ -f /etc/init.d/ibrix_fusionmanager ]] && /etc/init.d/ibrix_fusionmanager stop
   [[ -f /etc/init.d/ibrix_server ]] && /etc/init.d/ibrix_server stop

umount_iso iso9660  /mnt/cdrom
(( nfs )) && umount_iso nfs  /mnt/nfs

# start ibrix FM and Seg Server 
#
   [[ -f /etc/init.d/ibrix_fusionmanager ]] && /etc/init.d/ibrix_fusionmanager start
   [[ -f /etc/init.d/ibrix_server ]] && /etc/init.d/ibrix_server start
