#!/bin/bash

# check devices to use for file system
#   Devices are checked for multipath and for existing FS
# select from that list of devices
# create file system
# start-up ibrix
# configure VDS domain
# start emulator
# ##
# command can also, stop, start, restart
#                  enumerate disks
#################################################

#
# print banner with stars
#
function msg(){
	local cnt=${#1}
	local sline=''
        local c
	for ((c=1;c<=(cnt+4);c++)); { sline=${sline}'*'; }
	echo -e "\n\t${sline}\n\t* ${@}\n\t${sline}\n"
} # end msg()

# set absolute path for either multi-path or direct san disks
function setDevPth() {
    local v=${1}
    (( HAVEMP )) && echo "/dev/mpath/${v}"
    (( ! HAVEMP )) && echo "/dev/${v}"
} # end setDevPth

# enumerate disks available for creating File Systems
# provide information about possible current state to device
# this may help reduce using an already active disk
#
function devInit() {

    if (( DISKS ))
    then
        if [[ -z ${FMT_0} ]]
        then
            read -p"source location include 'fmt_0' as last element: " FMT_0
            export FMT_0=${FMT_0}
        fi
    fi

    Dgrub='/boot/grub'
    GRUB=${Dgrub}"/grub.conf"
    DEVMP=${Dgrub}"/device.map"

    # get root device from grub boot line
    rdev=$(grep kernel ${GRUB} |
            grep -v '^#'                     |
            awk '{for (f=1;f<NF;f++)
                    {
                    if ($f ~ /^root/) {
                        c=split($f,a,"=")
                        c1=split(a[c],v,"/")
                        print v[3]
                       }
                    }
                }')

    #
    #  Actual root device not supplied in grub
    #
    if (( ! ${#rdev} ))
    then
        rdev=$(df / | tail -1 |awk '{print $1}')
        if echo ${rdev} |grep -q cciss
        then
            # root not vg
            idev=$(awk '$0 !~ /^#/ {sub("/dev/","");print $NF}' ${DEVMP})
        fi
    else

        # determine the physical device from the lv name
        #
        idev=$(( vgdisplay -v ${rdev} 2>/dev/null |
                 awk '$0 ~ /PV Name/ {gsub("[[:digit:]]","")
                         sub("/dev/","");print $NF}'

        # also get the device map idea of the root device
        #
        awk '$0 !~ /^#/ {sub("/dev/","");print $NF}' ${DEVMP} ) |
        sort -u)
    fi

    HAVEMP=0
    MP='/sbin/multipath'
    if [[ -x ${MP} ]]
    then
        MPS=$(${MP} -l |
                awk '{if($1 ~ /mpath/) print $1}')
        if (( ${#MPS} ))
        then
            devs=(${MPS})
            HAVEMP=1
        fi
    fi

    # if no multipath devs, then use devices from partitions
    if (( ! ${HAVEMP} ))
    then
        # get the available partitions minus the boot/root devices
        devs=($(cat /proc/partitions |
                    grep sd |grep -v ${idev}|
                    awk '{print $NF}'))
    fi

    #
    # have user select the devices to use
    #
    msg "Devices"
    if (( DISKS ))
    then
        sdevs=(${devs[*]})
    else
        (( k = (${#devs[*]}+1) ))
        echo -e "Select the devices to use, one at a time, \c"
        echo "or 'ALL' (${k}) to use all devices"
        ((k+=1))
        echo "or 'QQ' (${k}) to end selection"
        j=0
        select wdev in ${devs[*]} ALL QQ 
        do
            if [[ ${wdev} = 'QQ' ]]
            then
                break
            elif [[ ${wdev} = 'ALL' ]]
            then
                sdevs=(${devs[*]})
                break
            else
                sdevs[${j}]="${wdev}"
                ((j+=1))
            fi
        done
    fi
   
    d=0;a=0
    for i in ${sdevs[*]}
    {
        local DEV=$(setDevPth ${i})

        echo -e "${DEV}##  \c"
        if ${FMT_0}/bin/ibfsck -n ${DEV} 2>&1 >/dev/null
        then
            usedDevs[$d]=${DEV}
            ((d+=1))
        else
            availDevs[$a]=${DEV}
            ((a+=1))
        fi
    }

    if ((d>0))
    then
        msg "These devices have IBRIX FS present"
        echo "${usedDevs[*]}"
    fi

    k=0
    for d in ${sdevs[*]}
    {
        vg="$(pvs 2>/dev/null |
        grep  ${d}      |
        awk '$1 ~ /dev/ {if (NF == 6) print}')"
        if (( ${#vg} ))
        then
            vdevs[$k]="${vg}"
            ((k+=1))
        fi
    }
    if ((k))
    then
        msg "Devices referenced in Volume Groups"
        for ((i=0;i<k;i++)); { echo  ${vdevs[$i]} ;}
    fi

    if ((a>0))
    then
        msg "Devices with no FS, unrecognized, or damaged FS"
        echo "${availDevs[*]}"
    fi

    if (( !DISKS && !YES ))
    then
        read -p"Continue (y/[n]): " ans
        [[ ${ans} != [yY] ]] && exit 3
    fi

    # if option to only lists disks, then exit
    (( DISKS )) && exit 0

    echo "write unique string to selected dev files"

    for i in ${sdevs[*]}
    {
        local DEV=$(setDevPth ${i})
        echo ${i}${i}${i}${i}${i}${i}${i}${i} > fillit
        dd if=fillit of=${DEV} count=1  >/dev/null 2>&1
    }

    echo "read strings back from dev files, should all be different"
    echo "if not then some are multi-path"

    for i in ${sdevs[*]}
    {
        local DEV=$(setDevPth ${i})
        echo -e "${DEV} \c"
        dd if=${DEV} of=out${i} count=1  >/dev/null 2>&1
        cat out${i}
    }
} # end devInit

#
# source config file and set hosts, sdevs, and isegs arrays
#
function restoreConfig() {
    configFile="${1}"
    . ${configFile}
    hosts=(${hosts_c})
    sdevs=(${sdevs_c})
    echo "${hosts_c}"
    echo "${hosts_n}"
    echo "${sdevs_c}"
    echo "${mount_point}"
    echo "${ifs}"
    echo "${FMT_0}"
    echo "${iseg_n}"
    echo "${idbg}"
    echo "${iallocp}"
    echo "${san}"
    echo "${Vdomain}"
    if (( ${#sdevs[*]} != iseg_n ))
    then
        export iseg_n=${#sdevs[*]}
        echo "# updated iseg_n" >> ${configFile}
        echo "export iseg_n=${iseg_n}" >> ${configFile}
        msg "iseg_n did not match number of devices, set iseg_n to #devs"
    fi
    j=0
    for ((i=0;i<iseg_n;i++))
    {
        ((segnum=i+1))
        echo "ISEGS for ${i}: ${hosts[${j}]} ${segnum} ${sdevs[${i}]}"
        isegs[${i}]="${hosts[${j}]} ${segnum} ${sdevs[${i}]}"
    }

} # end restoreConfig

#
# Save user inputs in config file for later re-use
# config files are of time stamped
#
function saveConfig() {
    ts=$(date '+%Y%m%d%H%M%S')
    configFile="${HOME}/config_$(hostname)_${ts}"
    cat /dev/null > ${configFile}
    echo "export HAVEMP=${HAVEMP}" >> ${configFile}
    echo "export hosts_c=\"${hosts[*]}\"" >> ${configFile}
    echo "export hosts_n=${hosts_n}" >> ${configFile}
    echo "export sdevs_c=\"$(echo ${sdevs[*]})\"" >> ${configFile}
    echo "export mount_point=${mount_point}" >> ${configFile}
    echo "export ifs=${ifs}" >> ${configFile}
    echo "export FMT_0=$FMT_0" >> ${configFile}
    echo "export iseg_n=${iseg_n}" >> ${configFile}
    echo "export idbg=0x3" >> ${configFile}
    echo "export iallocp=LOCAL" >> ${configFile}
    echo "export san=OFF" >> ${configFile}
    echo "export Vdomain=${Vdomain}" >> ${configFile}
    msg "Saved config in file: ${configFile}"
} # end saveConfig

# echo command then execute it
# issue messages if command run in background
function doCmd() {
    if echo ${@} | grep -q '&$'
    then msg "starting in background"
    fi
    echo "    "${@}
    eval ${@}
    if jobs -l | grep -q "[[:digit:]]"
    then msg "background pid: $!"
    fi
} # end doCmd

#
# create file system with mkibfs
#
function f_mkibfs(){

    mkopts=' '
    ((YES)) && mkopts='-F'
    MKIBFS="$FMT_0/bin/mkibfs ${mkopts}"

    function makeseg() {
        ihost=$1
        iseg=$2
        idev=$(setDevPth ${3})
        echo -e "\n========================================================" 
        echo makeseg $ihost $iseg $idev $my_host_id
        if [ ! "$ihost" = "$my_host_id" ] ; then
            echo SKIP -- dd if=/dev/zero of=$idev count=100 
        else
            #echo $FMT_0/bin/mkibfs $idev $ifs $ifs $iseg $iseg_n $ihost
            #echo  +++ -J size=4
            doCmd "dd if=/dev/zero of=$idev count=100"
            doCmd "${MKIBFS} $idev $ifs $ifs $iseg $iseg_n $ihost"
        fi
    } # end makeseg

    function export_id() {
        ihost_n=$1
        host_id=$2
        echo export_id $ihost_n $host_id _my_h $_my_host
        if [ "$ihost_n" = "$_my_host" ] ; then
            doCmd "export my_host_id=$host_id"
        fi
    } # end export_id

    for ((h=0;h<${hosts_n};h++));{ export_id ${hosts[${h}]} ${hosts[${h}]}; }

    for  ((h=0;h<${#isegs[*]};h++)); { makeseg ${isegs[${h}]} ; }

} # end f_mkibfs


#######
# START
# start ibrix
#   - determine kernel version
#   - rtool host info to use
#   - rtool the segments
#   - install kernel modules
#   - set debug
#   - set allocation policy
#   - mount file system
#   - start services
#######
function start() {

    if [ "$FMT_0" = "" ]; then
        echo 'FMT_0 not set!'
        exit 2
    fi

    msg "Start Ibrix"

    RTOOL="$FMT_0/bin/rtool"
    linSrc="$FMT_0/bin/linux_src_info"
    export _kernel_ver=`$linSrc --version | cut -d '.' -f 1,2`

    start_host=$_my_host

    if [ "$idbg" = "" ]; then idbg=0xffffff ; fi

    function dohost() {
        echo "dohost() p1=" $1 ", p2=" $2 ", p3=" $3
        ihost=$1
        idhost=$2
        t=$3
        if [ ! "$ihost" = "$_my_host" ] ; then
            doCmd "${RTOOL} defhost -udp $ihost $idhost $t"
        else
            doCmd "${RTOOL} localhost -udp $idhost"
        fi
    }

    function modseg() {
        ihost=$1
        iseg=$2
        idev=$(setDevPth $3)
        doCmd "${RTOOL} modseg $idev $ifs $ifs $iseg $iseg_n $ihost"
    } # end modseg

    DNAME=$FMT_0/bin
    IPFS1_MOD=$DNAME/ipfs1.`uname -r`.`$linSrc --arch`.o
    IBRIX_MOD=$DNAME/ibrix.`uname -r`.`$linSrc --arch`.o

    if [ ! -f $IPFS1_MOD ] ; then
        echo " cannot find file " ${IPFS1_MOD}
        IPFS1_MOD=$DNAME/ipfs1.o
    fi

    if [ ! -f $IBRIX_MOD ] ; then
        echo " cannot find file " ${IBRIX_MOD}
        IBRIX_MOD=$DNAME/ibrix.o
    fi

    if [ "$_kernel_ver" = "2.6" ] ; then
        doCmd "insmod $IPFS1_MOD"
        doCmd "insmod $IBRIX_MOD"
    else
        msg "Unsupported Kernel: ${_kernel_ver}"
    fi

    doCmd "${RTOOL} debug trace $idbg"

    msg "Hosts are: ${hosts[*]}"
    for ((h=0;h<${#hosts[*]};h++)); { dohost ${hosts[${h}]} ${hosts[${h}]} ; }

    for ((h=0;h<${#isegs[*]};h++)); { modseg ${isegs[${h}]} ; }

    doCmd "${RTOOL}   allocp $ifs $iallocp"

    doCmd "mount -t ibrix $ifs /ibrix -o fsname=$ifs"

    doCmd "${RTOOL} startexport"
    df -t ibrix

} # end start

#
# configure VDS domain and start emulator
#
function configEmulate() {
    mkdir -p ${mount_point}/${Vdomain}
    msg "Configure domain and start Emulator"
    doCmd "${FMT_0}/bin/${VCONFIG} -s ${Vdomain} ${mount_point}/${Vdomain}"
    if ((GDB))
    then
        vdsLog="${HOME}/vdsGdbLog.log"
        gdbts=$(date '+%Y%m%d%H%M%S')
        gdbcmds="${HOME}/gdbcmds${gdbts}"
        gdblog="set logging file ${vdsLog}\nset logging on"
        emuSrc="dir ${FMT_0}/tools/vdsi:${FMT_0}/tools/lib:${FMT_0}/tools"
        emuCmd="file ${FMT_0}/bin/${VEMUL}\nset args -d ${Vdomain} ${mount_point} ${EMUARGS}"
        msg "create gdb commands file ${gdbcmds}"
        echo -e "${gdblog}\n${emuSrc}\n${emuCmd}" > ${gdbcmds}
        \rm -f ~/gdbcmds ; ln -s ${gdbcmds} ~/gdbcmds
        doCmd "gdb --silent -x ${gdbcmds}"
    else
        doCmd "${FMT_0}/bin/${VEMUL} ${EMUARGS} -d ${Vdomain} ${mount_point} &"
    fi

} # end configEmulate

function killEmu() {
    PID=$(pgrep ${VEMUL})
    if ((${#PID}))
    then
        msg "kill emulator ${PID}"
        kill ${PID} 
        sleep 3
    fi
}

#
# remove ibrix kernel modules
#
function rmMods() {

    OK=1
    if mount -t ibrix |grep -q ${mount_point}
    then
        OK=0
        msg "unmount ${mount_point}"
        if umount ${mount_point} ; then OK=1 ;fi
    fi
    for m in ${KMODS}
    {
        if lsmod |grep -q ^${m}
        then
            msg "remove ${m} kernel module"
            if rmmod ${m}; then OK=1
            else OK=0;fi
        fi
    }
} # end rmMods

#
# Start nfs services (assumes source path is on NFS)
# stop emulator and ibrix
# start ibrix, if '-e' option then also start emulator
#
function restart() {

    msg "restart NFS"
    service nfs restart

    OK=0
    stop
    if (( OK )); then start
        if (( EMU )); then configEmulate; fi
    fi

} # end restart

#
# mount point is needed, prompt if not set
# kill emulator
# unmount file system
# unload kernel modules
# exit if not called by restart
##############
function stop() {

    if [[ -z ${mount_point} ]]
    then
        # need mount point
        read -p"file system mount point (def='/ibrix'): " mount_point
        [[ -z ${mount_point} ]] && mount_point="/ibrix"
        export mount_point=${mount_point}
    fi

    killEmu
    rmMods
    (( ! RESTART )) && exit 0

} # end stop

#
# populate segments array
#
function setIsegs() {
    (( segSplit = iseg_n/hosts_n ))
    j=0
    for ((i=0;i<segSplit;i++))
    {
        ((segnum=i+1))
        echo "ISEGS for ${i}: ${hosts[${j}]} ${segnum} ${sdevs[${i}]}"
        isegs[${i}]="${hosts[${j}]} ${segnum} ${sdevs[${i}]}"
    }
} # end setIsegs

#
# hopefully helpful information
#
function usage() {
    ts=$(date '+%Y%m%d%H%M%S')
    h=$(hostname -s)
	echo -e "\nusage: ${PROG} [-C ARG|-c][-I ARG][-M ARG][-E 'args'][-s|k|r] | [-fde|-A] [-y][-g]"
    echo -e "\tC config file -use config file created with 'c' option"
    echo -e "\tc             -prompt for needed info, save in config file"
    echo -e "\tI source path -path to and including fmt_0 (useful with -d)"
    echo -e "\tM path        -mount point of file system (useful with -k)"
    echo -e "\ts             -start ibrix, assumes FS created"
    echo -e "\tk             -stop emulator, unmount FS, unload kernel mods"
    echo -e "\tr             -restart,'-k' activities, then '-s', can use with '-e'"
    echo -e "\tf             -create file system then stop"
    echo -e "\td             -enumerate disks then stop"
    echo -e "\te             -start Emulator, assumes Ibrix is running"
    echo -e "\tA             -Do all steps, through starting emulator"
    echo -e "\ty             -Do not prompt for confirmation"
    echo -e "\tg             -Run emulator under GDB"
    echo -e "\tE emulator args -Quoted options beyond required '-d' and path"
    echo "Example:"
    echo "Enumerate available disks and stop, provide src path. "
    echo -e "\t${PROG} -d -I /src/fmt_0"
    echo "Create file system, save the config input, and stop"
    echo -e "\t${PROG} -f -c"
    echo "Start Ibrix using values read from config file"
    echo -e "\t${PROG} -s -C config_${h}_${ts}"
    echo "Re-Start Ibrix using values read from config file"
    echo -e "\t${PROG} -r -C config_${h}_${ts}"
    echo "Start VDS emulator on already running Ibrix using config file"
    echo -e "\t${PROG} -e -C config_${h}_${ts}"
    echo "From config file, create file system, start Ibrix, and emulator"
    echo -e "\t${PROG} -A -C config_${h}_${ts}"
    echo "Kill ibrix and emulator, specify ibrix mount point"
    echo -e "\t${PROG} -k -M /ibrix"
	exit 2
} # end usage

##############
#    MAIN
##############

# initialize some common variables
export _my_host=`hostname -s`
DNAME=${0%/*}
PROG=${0##*/}
KMODS='ibrix ipfs1'
VCONFIG="vds_config"
VEMUL="vds_emulator"
HAVEMP=0

# check that some arguments were supplied
((!${#})) && usage

#
# process command line
#
RESTORE=0;MKFS=0;START=0;RESTART=0;CONFIG=0;DISKS=0;ALL=0;EMU=0;YES=0
EMUARGS=""
while getopts :cC:I:M:E:fskrdAeyg OPT; do
    case $OPT in
        c) # create config file only
            CONFIG=1	
      ;;C) # use supplied config file
            configFile="$OPTARG"
            RESTORE=1
      ;;f) # Create file system then stop
            MKFS=1
      ;;s) # Start Ibrix
            START=1
      ;;k) # Kill Ibrix
            KILL=1
      ;;r) # restart (kill, then start) Ibrix
            RESTART=1
      ;;d) # List available disks then exit
            DISKS=1
      ;;A) # configure disk, create file system, start Ibrix, start VDS emulator
            ALL=1
      ;;e) # Start VDS emulator, assumes setup is complete
            EMU=1
      ;;I) # ibrix source location
            FMT_0="${OPTARG}"
      ;;M) # ibrix fs mount point
            mount_point="${OPTARG}"
      ;;y) # do not prompt at safety points
            YES=1
      ;;g) # launch emulator under gdb
            GDB=1
      ;;E) # launch emulator with args
            EMUARGS="${OPTARG}"
      ;;*)  usage
    esac
done

#
# validate option combinations
#
if (( CONFIG && RESTORE ));then
    msg "Cannot have 'c' option and 'C' option.";usage
fi

if (( START && RESTART ));then
    msg "Cannot have both 's' and 'r' options";usage
fi

if (( ALL && ( KILL || RESTART ) ));then
    msg "Cannot use 'k' or 'r' with 'A'";usage
fi

if (( ( START||RESTART||EMU||MKFS||ALL ) && ! ( RESTORE || CONFIG ) ));then
    msg "Requires a config file option 'c' or 'C'.";usage
fi

if (( ( ${#FMT_0}||${#mount_point} ) && ! ( START||RESTART||EMU||MKFS||ALL ) ));then
    msg "Requires an action option like 'f' or 'A'.";usage
fi

#
# Read in values from config file
#
(( RESTORE )) &&  restoreConfig ${configFile}

# list disks and exit if '-d'
#
(( DISKS )) && devInit

#
# prompt user for needed config values
# saveConfig will later save these for later use
#
if (( CONFIG ))
then
    read -p"source locations include 'fmt_0' as last element: " FMT_0
    export FMT_0=${FMT_0}

    devInit

    read -p"name of file system (def='test'): " ifs
    [[ -z ${ifs} ]] && ifs='test'
    export ifs=${ifs}

    # read -p"number of segments to use(def=${#sdevs[*]}): " iseg_n
    export iseg_n=${#sdevs[*]}
    export idbg=0x3

    export iallocp=LOCAL
    export san=OFF

    read -p"file system mount point (def='/ibrix'): " mount_point
    [[ -z ${mount_point} ]] && mount_point="/ibrix"
    export mount_point=${mount_point}

    read -p"VDS domain (def='xyz'): " Vdomain
    [[ -z ${Vdomain} ]] && Vdomain="xyz"
    export Vdomain=${Vdomain}

    read -p"number of hosts to use(def=1): " hosts_n
    [[ -z ${hosts_n} ]] && hosts_n=1
    export hosts_n=${hosts_n}

    echo "host(s) to use"
    for ((i=0;i<${hosts_n};i++))
    {
        hn=$(hostname -s)
        read -p"hostname ${i} (def: ${hn}): " ihost
        [[ -z ${ihost} ]] && ihost=${hn}
        hosts[$i]="${ihost}"
    }
fi # end if CONFIG

(( KILL )) && stop

if (( ! RESTORE ))
then
    saveConfig
    setIsegs
fi

(( ALL ))           && rmMods     # start from known state
(( MKFS  || ALL ))  && f_mkibfs
(( START || ALL ))  && start
(( CONFIG )) && msg "config saved in ${configFile}"
(( EMU   || ALL ))  && configEmulate
(( RESTART ))       && restart
