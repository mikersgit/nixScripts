#!/bin/bash

# get the FM IP and port info regardless of which node you are on
# details in Ibrix_fm.sh
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
	echo "usage: ${0##*/} shareName"
	exit 2
fi

SHNAME="${1}"
while getopts :s OPT; do
    case $OPT in
        s) 
            SHNAME="${OPTARG}"
        ;;*)
	        echo "usage: ${0##*/} shareName"
	        exit 2
    esac
done
shift $[ OPTIND - 1 ]

getFM

carg0='http://'
carg1='/fusion/servers/*all*/cifsshares/'${SHNAME}'?cifsType=likewise&view=info&media=txt&shareUserAction=list'
${CURL} ${carg0}${LOC}${carg1}
