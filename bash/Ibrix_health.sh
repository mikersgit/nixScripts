#!/bin/bash

# get the FM IP and port info regardless of which node you are on
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

if (( $# < 1 ))
then
	echo "usage: ${0##*/} [-il]"
	exit 2
fi

while getopts :il OPT; do
    case $OPT in
    i)
   VIEW='info'
    ;;l)
   VIEW='list'
    ;;*)
	echo "usage: ${0##*/} [-il]"
	exit 2
    esac
done

getFM

carg0='http://'
carg1='/fusion/engines/*all*/health?view='${VIEW}'&media=txt'
${CURL} ${carg0}${LOC}${carg1}
