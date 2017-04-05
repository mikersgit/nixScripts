#!/bin/bash

# Command to test logging behavior of Continuous CRR and native snapshots
#
# creates CRR task, set debug, then snap tree, then touches file and creates snaps in a loop
# flushes logs
# creates the files on segment local to current host. this assumes the availability of 'ibtouch'
# from fmt_0/tools/ibfsckII/ibtouch
#
# In the case where Run Once is selected, then CRR is started at the _end_ after snaps created
# and the first snap created is replicated to a subdirectory of the target file system.
#
#

function usage() {

	echo "usage: ${1} [[-d] -s srcFS (no slashes) -t targetFS (no slashes)] [-k|-O] [-S] [-?h usage]"
        echo -e "\t-d  Remove snapshots, unmark snaptree, and exit."
        echo -e "\t-s  file system in which to create snaps, and from which to replicate."
        echo -e "\t-t  file system to which to replicate."
        echo -e "\t-k  kill continuous CRR task at end of run."
        echo -e "\t-S  Stop existing CRR tasks before start."
        echo -e "\t-O  Do RunOnce of first snap taken, after all snaps taken (unsets -k)."
	exit 2
}

DELSNAPS=0
killcrr=0
stopcrr=0
runonce=0
while getopts :ds:t:kSO?h OPT; do
    case $OPT in
	s)
	s_fs="$OPTARG"
	;;t)
	t_fs="$OPTARG"
	;;d)
	DELSNAPS=1
	;;k)
	killcrr=1
	;;S)
	stopcrr=1
	;;O)
	runonce=1
	;;?)
	
	;;h)
	
	;;*)
	usage ${0##*/}
    esac
done
shift $[ OPTIND - 1 ]

if [[ -z ${s_fs} || -z ${t_fs} ]]
then
   echo "Must specify source and target file systems"
   echo "One of these:"
   df -t ibrix |grep -v ^Filesystem |awk '{print $1}'
   usage ${0##*/}
fi

# unset killcrr if runonce
(( runonce )) && killcrr=0

#
# print banner with stars
#
function msg(){
	local cnt=${#1}
	local sline=''
        local c
	# create line of stars 4 longer than length of first argument to msg
	for ((c=1;c<=(cnt+4);c++)); { sline=${sline}'*'; }
	echo -e "\n\t${sline}\n\t* ${@}\n\t${sline}\n"
} # end msg()

IBBASE='/usr/local/ibrix'
IBPATH=${IBBASE}'/bin'
IBLOG=${IBBASE}'/log'
SNAPCMD=${IBPATH}'/ibrix_snap'
CRRCMD=${IBPATH}'/ibrix_crr'
CRRCTL=${IBPATH}'/ibrcfrctl'
DAEMON='ibrcfrd'

# create directory structure with a file at the end with date info in it
s_dir='mwr0/mwr1/mwr2'
s_file=/${s_fs}/${s_dir}/$(date '+%d%H%M%S')dateFile
s_bname='mwr'

# Number of snapshots to create - 1
cnt=4

#
# delete snapshots and UN mark directory as snaptree
#
function delete_snaps() {

        # could also do something like
        # ibrix_snap -l -s | awk 'BEGIN{getline;getline}{print}' | while read fs sn st
        # do
        #  ibrix_snap -d -f ${fs} -P ${st} -n ${sn}
        # done

 	msg "Remove any snapshots from ${s_fs}"
        local yr=$(date '+%Y')
 	for s in $(${SNAPCMD} -l -s -f ${s_fs} | grep ${yr} | awk '{print $2}')
 	{
   		${SNAPCMD} -d -f ${s_fs} -P /${s_fs}/${s_dir} -n ${s}
 	}
 	msg "Reclaim snapspace in ${s_dir}"
        ibrix_snapreclamation -r -f ${s_fs}
        sleep 10
 	msg "UNmark snaptree ${s_dir}"
 	${SNAPCMD} -m -U -f ${s_fs} -P /${s_fs}/${s_dir}
} # end delete_snaps()

if (( DELSNAPS ))
then
	delete_snaps
	exit $?
fi

function stopCRR() {
        msg "Stop any existing CRR tasks"
        TSKPFX='crr'
	# kill all tasks
	JNUM=$(${CRRCMD} -l |grep ^${TSKPFX} |awk '{sub("'${TSKPFX}'-","",$1);printf("%d ",$1)}')
        for J in ${JNUM}
        {
	        ${CRRCMD} -k -n ${TSKPFX}-${J}
        }
}

(( stopcrr )) && stopCRR

msg "Clear /${s_fs}/mwr0 and /${t_fs}/mwr0 directories"
rm -rf /${s_fs}/mwr0
rm -rf /${t_fs}/mwr0
[[ ! -d /${s_fs}/${s_dir} ]] && mkdir -p /${s_fs}/${s_dir}

#
# show the inum via several tools
# if the fsobj is a file, then cat its contents and get the inum of its parent too
#
function show_inum() {
	local fsobj=${@}
	if [[ -f ${fsobj} ]]
	then
		msg "PARENT ${fsobj%/*}"
		show_inum ${fsobj%/*}
		msg "CONTENTS ${fsobj}"
		cat ${fsobj}
	fi
	msg "get_seg ${fsobj}"
	${IBPATH}/get_seg ${fsobj}
	${IBPATH}/get_seg ${fsobj}| awk '$1 !~ /^seg/ {print $2}' |
	while read INUM
	do
		msg "inum2name of ${INUM}"
		${IBPATH}/inum2name /${s_fs} ${INUM}
	done
	msg "text3 inum of ${fsobj}"
	ls -di ${fsobj}
} # end show_inum()

#
# figure out a local segment, so ibtouch can be used to place the file
# on the local node, thus making sure the CRR logs for operations are
# also on this node.
function mysegs() {
        rtool enumseg |
                awk '{if ( $1 ~ /segnum=/ ) {
                        sub("segnum=","",$1)
                        s=$1 }
                        if ( $1 ~ /fsname/ ) f=$NF
                        if ( $1 ~ /host_name/ ) {
                         h=$NF
                         printf("%s %s %s\n",h,f,s)
                         }
                        }' |
                grep ${s_fs} | grep $(hostname) |head -1|awk '{print $NF}'
}

show_inum /${s_fs}/${s_dir}

# sets maximum cfrd debug
CMD=${CRRCTL}
port=$(ps -o args -p$(pgrep ${DAEMON})| awk 'FS="=" {printf("%s",$3)}')
${CMD}  --op=udaemon --port=${port} --logflag=0x00203016

# put supplied message and current date/time in file
# create file on local segment if it doesn't already exist
#
function touch_sfile() {

        if [[ ! -f ${s_file} ]]
        then
                myseg=$(mysegs | awk '{print $1}')
		if [[ ! -x ${IBPATH}/ibtouch ]]
		then
			msg "ERROR: need fmt_0/tools/ibfsckII/ibtouch copied to\n\t* ${IBPATH}/ibtouch"
                        exit 2
		else
                	${IBPATH}/ibtouch -seg ${myseg} ${s_file}
		fi
        fi
        echo -e "\t${@}  \c " >> ${s_file}
        date >> ${s_file}
}

#
# start continuous CRR task
# and record the task id incase "killcrr" selected
function ContCRR() {
        msg "start Continuous CRR (same cluster different file system)"
        #
        tmpfl=$(mktemp)
        ${CRRCMD} -s -f ${s_fs} -F ${t_fs} |
                awk '{print ;if ($1 ~ /Submit/) task=$NF}; END {printf("%s\n",task)}' 2>&1 > ${tmpfl}
                cat ${tmpfl}
                taskID=$(tail -1 ${tmpfl})
                rm -f ${tmpfl}
        # let replication drain
        sleep 4
}

#
# start run once CRR, create target subdir, and select the oldest snapshot on the fs of interest
#
function RunOnceCRR() {
        t_dir='RuOn'
        #
        mkdir -p /${t_fs}/${t_dir}
        snSrc=$(${SNAPCMD} -l -s -f ${s_fs} | awk '{p=$NF;s=$(NF-1)}END{printf("%s/.snapshot/%s\n",p,s)}')
        msg "start RunOnce CRR of snap ${snSrc}\n\t* to same cluster /${t_fs}/${t_dir}"
        ${CRRCMD} -s -o -f ${s_fs} -S ${snSrc} -F ${t_fs} -P ${t_dir}
        sleep 5
}

# if runonce not set, default to continuous
(( ! runonce )) && ContCRR

touch_sfile "First touch"

# sleep a few seconds to let the replication complete
sleep 4

msg "List any snapshots"
${SNAPCMD} -l # list snaps

# mark snap tree
#
${SNAPCMD} -m -f ${s_fs} -P ${s_dir}
touch_sfile "Marked snaptree"

((c=cnt+1))
msg "Create $c snapshots"

for ((i=0;i<=cnt;i++))
{
        # mark file then create snapshot
        touch_sfile "created ${i} snapshot"
        msg "${s_file} contents\n\t"
	show_inum ${s_file}
        ${SNAPCMD} -c -f ${s_fs} -P ${s_dir} -n ${s_bname}${i}

        msg "Created ${i} snapshot"

        # sleep a few seconds to let the replication complet
        sleep 4
}

msg "List any snapshots"
${SNAPCMD} -l # list snaps
${SNAPCMD} -l -s -f ${s_fs}

(( runonce )) && RunOnceCRR

msg "flush crr logs"
${CRRCTL} --op=udaemon --port=9171 --set-mask=1

msg "List crr tasks"
${CRRCMD} -l
(( killcrr )) && msg "kill most recent one started (${taskID})"
(( killcrr )) && ${CRRCMD} -k -n ${taskID}

msg "tail of ${IBLOG}/${DAEMON}.dbg"
tail ${IBLOG}/${DAEMON}.dbg

ls -lR /${t_fs}
