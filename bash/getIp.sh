#!/bin/bash

# get IP addresses for any interface, except loopback, that is up

# -c for compact output

#
# source message function
#
cmdDir=${0%/*}
COMPACT=0
if [[ ${cmdDir} = ${0} ]]
then
        cmdDir='.'
fi

if [[ -f  ${cmdDir}/msg.source ]]
then
        . ${cmdDir}/msg.source
else
        alias msg=echo
fi

# get IPv4 address for specified nic
if [[ ${1} = "-c" ]] 
then
   COMPACT=1
   shift 1
fi

if (( ${#} ))
then
        declare -a nics=(${@})
else
        declare -a nics=($(/sbin/ip link show up |grep -v -e lo: -e loop|grep ^[[:digit:]]|cut -d : -f 2))
fi

#
# get addresses for each
#
for d in ${nics[*]}
{
         if (( COMPACT ))
         then
            echo -e "${d} \c"
         else 
            msg "${d}"
         fi
        /sbin/ip -f inet addr sh ${d} |grep inet|
                    awk '{sub("/"," ");printf("%s\t",$2)}'
        (( COMPACT )) || echo
}
(( COMPACT )) && echo
