#!/bin/bash

OUTFL=~/build_out.txt
MODULE='lwio'

# Do incremental build of specified module
#
function makeModule() {
        local mod=${1}
        if [[ ! -x ./mkcomp ]]
        then
                echo "mkcomp not found, exiting"
                exit 1
        fi

        ./mkcomp --debug ${mod} 2>&1 | tee ${OUTFL}

        read -p "Package? [y]/n: " ans

        if [[ ${ans} = [nN] ]]
        then
                :
        else
                echo -e "++++++++++++\nPackaging\n++++++++++++\n"
                ./mkpkg --debug all 2>&1 | tee -a ${OUTFL}
        fi

} # end makeModule


# make sure we're in 'build',
# then do either full make ($1 = ALL), or incremental
#
if [[ ${PWD##*/} = build ]] #{
then
        if [[ ${1} = ALL ]] #{
        then
                make 2>&1 | tee ${OUTFL}
        else
                makeModule ${MODULE}
        fi #}
else
        echo "Not in 'build' directory"
        exit 1
fi #}
