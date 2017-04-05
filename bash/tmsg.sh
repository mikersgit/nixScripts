#!/bin/bash
# source in the message printing function
# assumes entire 'mwroberts/bin' directory is available
#

cmdDir=${0%/*}
if [[ ${cmdDir} = ${0} ]]
then
        cmdDir='.'
fi

. ${cmdDir}/msg.source

msg "sourced this\n\t* info"
