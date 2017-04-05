#!/bin/bash

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
}

restoreConfig ${1}

mkdir -p ${mount_point}/${Vdomain}

${FMT_0}/bin/vds_config -s ${Vdomain} ${mount_point}/${Vdomain}
${FMT_0}/bin/vds_emulator -d ${Vdomain} ${mount_point}

