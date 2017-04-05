#!/bin/bash

# select drive devices to use for file system creation.
# present a selection list from non-root/boot devs
#
# script to check if devices are multipath. Write letters to device
# and read them back.
#################################################

function devInit() {
    # get root device from grub boot line
    rdev=$(grep kernel /boot/grub/grub.conf |
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

    # determine the physical device from the lv name
    #
    idev=$(( vgdisplay -v ${rdev} 2>/dev/null |awk '$0 ~ /PV Name/ {gsub("[[:digit:]]","");sub("/dev/","");print $NF}'

    # also get the device map idea of the root device
    #
    awk '$0 !~ /^#/ {sub("/dev/","");print $NF}' /boot/grub/device.map ) | sort -u)

    # get the available partitions minus the boot/root devices
    declare -xa devs=($(cat /proc/partitions | grep sd |grep -v ${idev}|awk '{print $NF}'))

    #
    # have user select the devices to use
    #

    echo "Select the devices to use, one at a time, or 'QQ' to end selection"
    echo "or 'ALL' to use all devices"
    j=1
    select wdev in ${devs[*]} QQ ALL
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
    echo ${sdevs[*]}
    
    echo "write unique string to selected dev files"

    for i in ${sdevs[*]}
    {
        echo "/dev/${i}"
        echo ${i}${i}${i}${i}${i}${i}${i}${i} > fillit
        dd if=fillit of=/dev/${i} count=1  >/dev/null 2>&1
    }

    echo "read strings back from dev files, should all be different"
    echo "if not then some are multi-path"

    for i in ${sdevs[*]}
    {
        echo -e "/dev/${i} \c"
        dd if=/dev/${i} of=out${i} count=1  >/dev/null 2>&1
        cat out${i}
    }
    echo "FDEVS ARE: ${sdevs[*]}"
} # end devInit

function restoreConfig() {
    configFile="${HOME}/config_$(hostname)"
    . ${configFile}
    echo "${hosts_c}"
    host=(${hosts_c})
    echo "${hosts_n}"
    echo "${sdevs_c}"
    sdevs=(${sdevs_c})
    echo "${mount_point}"
    echo "${ifs}"
    echo "${FMT_0}"
    echo "${iseg_n}"
    echo "${idbg}"
    echo "${iallocp}"
    echo "${san}"
}

function iprompt() {
    devInit
    echo "DEVS ARE: ${sdevs[*]}"
    read -p"source locations include 'fmt_0' as last element: " FMT_0
    export FMT_0=${FMT_0}

    echo "FMT_0=$FMT_0"

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

    read -p"number of hosts to use(def=1): " hosts_n
    [[ -z ${hosts_n} ]] && hosts_n=1
    export hosts_n=${hosts_n}

    echo "host(s) to use"
    for ((i=1;i<=${hosts_n};i++))
    {
        read -p"hostname ${1}: " ihost
        host[$i]="${ihost}"
    }
} # end iprompt

function saveConfig() {
    configFile="${HOME}/config_$(hostname)"
    cat /dev/null > ${configFile}
    echo "hosts_c=\"${host[*]}\"" >> ${configFile}
    echo "hosts_n=${hosts_n}" >> ${configFile}
    echo "sdevs_c=\"$(echo ${sdevs[*]})\"" >> ${configFile}
    echo "mount_point=${mount_point}" >> ${configFile}
    echo "ifs=${ifs}" >> ${configFile}
    echo "FMT_0=$FMT_0" >> ${configFile}
    echo "iseg_n=${iseg_n}" >> ${configFile}
    echo "idbg=0x3" >> ${configFile}
    echo "iallocp=LOCAL" >> ${configFile}
    echo "san=OFF" >> ${configFile}
}

declare -ax sdevs
iprompt
saveConfig
