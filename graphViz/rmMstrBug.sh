#!/bin/bash

# remove master bug and its target bugs from diagram

if (( ${#} < 2 ))
then
    echo "${0#*/} MasterBugNum diagramFile"
    exit 2
fi
temp=$(mktemp)
m=${1}
fl=${2}
cp ${fl} ${fl}_with${m}
sed "/${m}/d" ${fl} > ${temp}
if diff -q ${temp} ${fl} 2>&1 > /dev/null
then
    echo "same"
    rm -f ${temp} ${fl}_with${m}
else
    echo "differ"
    mv ${temp} ${fl}
fi
