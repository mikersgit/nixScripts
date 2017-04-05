#!/bin/bash

# get the ibrix_version info regardless of which node you are on
function getFM() {
    CURL='/usr/bin/curl -s'
    FMXML='/etc/ibrix/fusion.xml'
    #port=9007
    port=$(awk '$0 ~ /cliPort/ {i=match($3,/[[:digit:]]/)
                 print substr($3,i,4)}' ${FMXML})
    FMcurl='http://localhost:'${port}'/fusion/fm/fusionserver?view=info&media=txt'
    IP=$(${CURL} ${FMcurl}|head -1|awk '{print $NF}')

    [[ ${IP} == "(active)" ]] &&  IP="localhost"
    LOC="${IP}:${port}"
}

getFM

carg0='http://'
# to determine the curl string to send
# ibrix_version curl -l | cut -f4- -d '/'
carg1='/fusion/engines/*all*/versions?media=txt'

${CURL} ${carg0}${LOC}${carg1}
