#!/bin/bash

function extract() {
    local i=${1}
    echo "=========== $i ============"
    echo ${i} | awk '{if ($1 ~ /_vm/) print "        VM"
        else print "        HW"}'
    grep Total ${i}       | awk '{print $4 $5" "$6" "substr($7,0,3)}'
    grep "hp-smb-" ${i}   | awk '{print $3 $4" "$5}'
    grep "STORE ALL" ${i} | awk '{print $3 $4 $5" "$6}'
    grep "Mantis" ${i}    | awk '{print $3 $4" "$5}'
    grep -i -e "CUSTOM Feature" ${i} |
             awk '{print $4 $5 $6 $7 $8 $9 $10 $11 $12 $13}'
}

if (($# > 0))
then
    extract ${1}
else
    for i in *.html
    {
        extract ${i}
    }
fi
