#!/bin/bash

# INTER-CLUSTER (-V vip)
# setup two clusters to run continuous CRR with postmark as the load.
# This setup assumes that the 'ibrix_nic' configuration is already complete
# on both clusters.
#
# INTRA-CLUSTE (-I)
# setup two x9k file systems to run continuous CRR with postmark as the load.
#
# Actions taken:
#       1. register clusters with eachother via ssh (-V only)
#       2. export target file system via ssh (-V only)
#       3. pull postmark package to source cluster FM if needed
#       4. configure postmark for selected source file system
#       5. start continuous CRR task
#       6. start postmark
#       7. monitor target file system for completion of replication of
#          postmark test (0 files remaining on target file system)
#       8. stop continuous CRR task on completion
#       (9.) there is a 'takedown' function currently commented out
#            that could be used to un-export and un-register the clusters
#################################

# select src file system from mounted ibrix file systems
#
function selectSrcFS() {

        echo 'select file system to replicate and run postmark'
        select srcFS in $(df -t ibrix | awk '$1 !~ /^Fi/ {printf("%s\n",$1)}')
        do
                break
        done
} # end selectSrcFS



# use epoch seconds to calculate elapsed time
# Start timer
function start() {
        STRtime=$(date +%s)
}
# stop timer
function stop() {
        STPtime=$(date +%s)
        ((DIFFtime=STPtime-STRtime ))
}
# print formatted elapsed time
function pdelta() {
        local pstr="${sec} ${sstr}"
        (( min )) && pstr="${min} ${mstr} ${pstr}"
        (( hr )) && pstr="${hr} ${hstr} ${pstr}"
        (( dy )) && pstr="${dy} ${dstr} ${pstr}"
        msg "${pstr}"

}
# format elapsed time into N days N hours N minutes N seconds
function delta() {

        local rtime=${1}
        dy=0;hr=0;min=0;sec=0
        : ${rtime:=${DIFFtime}}

        (( (second=1) && ( minute = second * 60 ) && ( hour = minute * 60 ) && ( day = hour * 24 ) ))
        sstr='seconds'; mstr='minutes'; hstr='hours'; dstr='days'

        function calcTime() {
                local cstr=${1}
                local str=${2}
                local div=${3}
                local val=${4}
                local unit=0
                (( unit=rtime/div )) && eval ${val}=${unit}
                (( unit == 1 ))      && eval ${cstr}=$(echo ${str} | sed 's/s$//')
                (( rtime=${rtime}%${div} )) 
        }

        (( rtime >= day ))                    && calcTime dstr "${dstr}" ${day}    dy
        (( rtime >= hour && rtime < day ))    && calcTime hstr "${hstr}" ${hour}   hr
        (( rtime >= minute && rtime < hour )) && calcTime mstr "${mstr}" ${minute} min
        (( rtime < minute ))                  && calcTime sstr "${sstr}" ${second} sec
        pdelta
}

#
# initialize environment,
#  prompt for any required values not provided on command line
#
function initE() {

        fsbDir='/opt/fsbench'
        resDir='/root/postmarkres'

        # if source file system was not given on command line, prompt for value
        (( ${#srcFS} == 0 )) && selectSrcFS
        (( ${#targFM} == 0 && intraCl == 0 )) &&
            read -p"target FM VIP: " targFM
        (( ${#targFS} == 0 )) &&
            read -p"target FS name: " targFS 

        if (( intraCl && ${#targFM} ))
        then
                echo 'ERROR: -V and -I are mutually exclusive options'
                exit 2
        fi

        (( ! intraCl )) && 
                targCluster=$(ssh ${targFM} "${ibBin}/ibrix_fm_tune -l " |awk '$1 ~ /^clusterName/ {print $2}')
        srcCluster=$(${ibBin}/ibrix_fm_tune -l |awk '$1 ~ /^clusterName/ {print $2}')
        srcFM=$(${ibBin}/ibrix_nic -l |grep Cluster | grep ":[0-9] "| awk '{print $(NF-1)}')

} # end initE()


#
# print banner with stars
#
function msg(){
	local cnt=${#1}
	local sline=''
	# create line of stars 4 longer than length of first argument to msg
	for ((c=1;c<=(cnt+4);c++)); { sline=${sline}'*'; }
	echo -e "\n\t${sline}\n\t* ${@}\n\t${sline}\n"
} # end msg()

#
# determine if postmark and iozone are already installed
# if not then pull needed components from dogfood and install
#
function psmSetup() {
        hasFsbench=$(\ls ${fsbDir} 2>/dev/null| wc -l)

        psmPkg='rhel5_5_postmark_iozone.tar.bz'
        psmPkgLoc='http://16.125.127.75/home_dirs/mwroberts/bin'
        sysstatPkg='sysstat-7.0.2-3.el5.x86_64.rpm'

        if (( !hasFsbench ))
        then
                # do not pull pkg if already have it
                msg "checking for ${psmPkg}"
                cd
                [[ ! -f ${psmPkg} ]] && curl -o ${psmPkg} ${psmPkgLoc}/${psmPkg}
                cd /
                tar jxf ~/${psmPkg}
        fi

        hasStat=$(rpm -qa sysstat\*|wc -l)
        # do not install pkg if already have it
        if (( !hasStat ))
        then
                rpm -hiv ${fsbDir}/${sysstatPkg}
        fi

        if [[ -f ${fsbDir}/setup_postmark.pl && ${#srcFS} -gt 0 ]]
        then
                cd
                msg "remove previous postmark runs under ${resDir}"
                rm -rf ${resDir}*
                local here=$PWD
                msg "configure postmark run"
                cd ${fsbDir}
                resDir=$(${fsbDir}/setup_postmark.pl -k ${resDir} -f ibrix -m /${srcFS} |
                        grep ^creating |head -1|awk '{print $2}')
                cd ${here}
                if [[ ${#resDir} -eq 0 ]]
                then
                        echo "Could not determine postmark results directory"
                        exit 2
                fi
        else
                echo "no file system selected"
                exit 1
        fi

} # end psmSetup

#
# unexport file system and deregister clusters
# should not be called if intra cluster (intraCl==1)
#
function takeDown() {
        ssh ${targFM} "${ibBin}/ibrix_crr_export -U -f ${targFS}"
        ssh ${targFM} "${ibBin}/ibrix_cluster -d -C ${srcCluster}"
        ${ibBin}/ibrix_cluster -d -C ${targCluster}
}

#
# return 0 if running on active FM, 1 otherwise
#
function isActive() {
        ibBin='/usr/local/ibrix/bin'
        [[ ! -x ${ibBin}/ibrix_fm ]] && return 1
        return $(${ibBin}/ibrix_fm -i |
                awk '{if ($0 ~ /\(passiv/) print 1
                      if ($0 ~ /\(active/) print 0
                }')
} # end isActive()

#
# register source and target clusters with each other
# then export the target file system to the source cluster
# should not be called if intra cluster (intraCl==1)
#
function regAndExport() {

        # register clusters w/ eachother
        #
        msg "register with  ${targCluster}"
        ${ibBin}/ibrix_cluster -r -C ${targCluster} -H ${targFM}
        msg "register with  ${srcCluster}"
        ssh ${targFM} "${ibBin}/ibrix_cluster -r -C ${srcCluster} -H ${srcFM}"
        msg "export target file system ${targFS}"
        ssh ${targFM} "${ibBin}/ibrix_crr_export -f ${targFS} -C ${srcCluster}"
} # end regAndExport()

#
# start continuous CRR task
#
function startCRR() {

        msg "start continuous CRR from ${srcFS} to ${targFS}"
        tmpfl=$(mktemp)
        if (( intraCl ))
        then
                local Copt=""
        else
                local Copt="-C ${targCluster}"
        fi

        # start task and capture new task id
        ${ibBin}/ibrix_crr -s -f ${srcFS} ${Copt} -F ${targFS} |
        awk '{print ;if ($1 ~ /Submit/) task=$NF}; END {printf("%s\n",task)}' 2>&1 > ${tmpfl}
        cat ${tmpfl}
        taskID=$(tail -1 ${tmpfl})
        rm -f ${tmpfl}
} # end startCRR()

#
# stop CRR task
#
function stopCRR() {

        msg "Stop CRR task ${taskID}"
        ${ibBin}/ibrix_crr -k -n ${taskID}
} # stopCRR()

#
# start postmark task
#
function psmStart() {

        msg "Start postmark"
        cd ${resDir}
        start
        ${resDir}/postmark_run_script.sh
        stop
        delta
} # end psmStart()

#
# monitor target for file count going to zero
#
function targMonitor() {
        
        msg "monitor target for completion"
        cnt=99
        start
        date

        #
        # if intra cluster no ssh is needed
        # else setup ssh to target cluster
        #
        if (( intraCl ))
        then
                cntCmd=""
        else
                cntCmd="ssh ${targFM} "
        fi
        while (( cnt > 0 ))
        do
                cnt=$( eval ${cntCmd} "/bin/ls /${targFS}" | grep -v lost | wc -l)
                sleep 60
        done
        stop
        date
        delta
} # end targMonitor()


##                    ##
## Parse command line ##
##                    ##

targFM=''
targFS=''
srcFS=''
intraCl=0
while getopts f:V:F:I?hH OPT; do
    case $OPT in
        f)
        srcFS="$OPTARG"
	;;V)
	targFM="$OPTARG"
	;;F)
	targFS="$OPTARG"
	;;I)
	intraCl=1
	;;*)
	echo "usage: ${0##*/} [-f <source FS name>] [-V <target FM VIP>| -I (intraCluster)] [-F <target FS name>]"
	exit 2
    esac
done

        ##      ##
        ## MAIN ##
        ##      ##

# if this is the active FM then proceed, else exit
#
if isActive
then

        initE         # initialize environment

        (( intraCl )) || regAndExport  # register clusters and export target file system if not intraCluster

        startCRR      # start continuous CRR task

        psmSetup      # install/configure postmark

        psmStart      # start postmark load

        targMonitor   # monitor remote cluster/target file system for postmark completion

        stopCRR       # stop continuous CRR task

        # unexport file system and deregister clusters
        #
        ## takedown
else
        echo "This must be run on the active FM of a cluster"
        exit 1
fi
