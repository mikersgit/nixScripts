#!/bin/bash

# get the FM IP and port info regardless of which node you are on
function getFM() {
    FMCMD='/usr/local/ibrix/bin/ibrix_fm'
    CURL='/usr/bin/curl'

    port=$(${FMCMD} curl -i | cut -f3,3 -d ':' | cut -f1,1 -d '/')
    IP=$(${FMCMD} -i|head -1|awk '{print $NF}')

    [[ ${IP} == "(active)" ]] &&  IP="localhost"
}

getFM
echo ${IP}:${port}

# can be used to contruct curl command line like
# carg0='http://'
# carg1='/fusion/engines/*all*/versions?media=txt'
# ${CURL} ${carg0}${IP}:${port}${carg1}
