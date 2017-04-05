#!/bin/bash

# get the FM IP and port info regardless of which node you are on
function getFM() {
    CURL='/usr/bin/curl -s'
    FMXML='/etc/ibrix/fusion.xml'
    #port=9007
    #FMCMD='/usr/local/ibrix/bin/ibrix_fm'
    #port=$(${FMCMD} curl -i | awk -F : '{print substr($3,1,4)}')
    port=$(awk '$0 ~ /cliPort/ {i=match($3,/[[:digit:]]/)
                 print substr($3,i,4)}' ${FMXML})
    FMcurl='http://localhost:'${port}'/fusion/fm/fusionserver?view=info&media=txt'
    IP=$(${CURL} ${FMcurl}|head -1|awk '{print $NF}')

    [[ ${IP} == "(active)" ]] &&  IP="localhost"
    LOC="${IP}:${port}"
}

getFM

carg0='http://'
carg1='/fusion/fusionmanagers?view=list&media=txt'
echo "Active FM is: ${IP}"
${CURL} ${carg0}${LOC}${carg1}
