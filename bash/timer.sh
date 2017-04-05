#!/bin/bash


#
# print banner with stars
#
function msg(){
	local cnt=${#1}
	local sline=''
	# create line of stars 4 longer than length of first argument to msg
	for ((c=1;c<=(cnt+4);c++)); { sline=${sline}'*'; }
	echo -e "\n\t${sline}\n\t* ${@}\n\t${sline}\n"
} # end msg()

# use epoch seconds to calculate elapsed time
#
function start() {
        STRtime=$(date +%s)
}
function stop() {
        STPtime=$(date +%s)
        ((DIFFtime=STPtime-STRtime ))
}
function pdelta() {
        MSG='msg'
        local pstr="${sec} ${sstr}"
        if [[ ${1} = [f] ]]
        then
                (( min )) && pstr="${min} ${mstr} ${pstr}"
                (( hr )) && pstr="${hr} ${hstr} ${pstr}"
                (( dy )) && pstr="${dy} ${dstr} ${pstr}"
        fi
        ${MSG} "${pstr}"

}
function delta() {
        DIFFtime=${DIFFtime}
        local rtime=''
        local format="f"
        while getopts r:s: OPT; do
                case $OPT in
                        r) rtime=${OPTARG} ;;
                        s) format=${OPTARG} ;;
                esac
        done

        dy=0;hr=0;min=0;sec=0
        : ${rtime:=${DIFFtime}}

        sstr='seconds'; mstr='minutes'; hstr='hours'; dstr='days'

        if [[ ${format} = [s] ]]
        then
                sec=${rtime}
        else
                (( (second=1) && ( minute = second * 60 ) && ( hour = minute * 60 ) && ( day = hour * 24 ) ))

                function calcTime() {
                        local cstr=${1}
                        local str=${2}
                        local div=${3}
                        local val=${4}
                        local unit=0
                        (( unit=rtime/div )) && eval ${val}=${unit}
                        (( unit == 1 ))      && eval ${cstr}=$(echo ${str} | sed 's/s$//')
                        (( rtime=${rtime}%${div} )) 
                }

                (( rtime >= day ))                    && calcTime dstr "${dstr}" ${day}    dy
                (( rtime >= hour && rtime < day ))    && calcTime hstr "${hstr}" ${hour}   hr
                (( rtime >= minute && rtime < hour )) && calcTime mstr "${mstr}" ${minute} min
                (( rtime < minute ))                  && calcTime sstr "${sstr}" ${second} sec
        fi

        pdelta ${format}
}
function doSleep() {
        echo "testing ${1} sleep"
        sleep $1
        stop
        date
        delta -s f
}

start
date
doSleep 1
doSleep 3
doSleep 60
#doSleep 61
#doSleep 119
#doSleep 121

 #STRtime=0
 #STPtime=${1}
#((DIFFtime=STPtime-STRtime ))
#delta -r ${DIFFtime} -s s
