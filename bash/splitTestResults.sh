#!/bin/bash
for i in ${1}
{
    outfl=$(echo ${i}|
        awk '{split($0,a,"-");print a[1] a[2] substr(a[3],1,4)}')
    ~/bin/extractTestResults.sh ${i} >> ${outfl}.tst
}
