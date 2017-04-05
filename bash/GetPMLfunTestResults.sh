#!/bin/bash

# Parse the "last successful" jenkins web page for the build number
# Pull the raw console output into file with build number
# parse PML fun test console output to create a summary of the
# tests run and results
# Michael Roberts 24-Jan-2014

#get latest build number
bldNum=$(curl http://10.31.4.172:8080/view/Protocols%20PML/job/Protocols_PML_Summary/lastSuccessfulBuild/ 2>/dev/null |
    grep 'Build #' | awk '{sub("#","",$2);print $2}')

input="PMLConsoleText_bld${bldNum}"

#pull raw console output from jenkins
curl -o ${input} http://10.31.4.172:8080/view/Protocols%20PML/job/Protocols_PML_Summary/lastSuccessfulBuild/consoleText 2>/dev/null 

output="PMLtestResults_${bldNum}.txt"

awk 'BEGIN {print "results and test case index at the end of report"}
    {
    if ($5 ~ /START/) { 
    sub("/root/funtest/test/","",$6)
    TC=$4
    lstr="**************************"
    printf("\n\t%s\n\t%s - %s\n\t%s\n",lstr,TC,$6,lstr)
    for (i=1;;i++)
    {
     getline
     if ( NF > 3 && ($5 !~ /DONE/ && $4 !~ /Skipped/)) print
     if ( $5 ~ /DONE/ ) next
    }
    print
    }
    if ( $0 ~ /Test Suite Result/) {
        print
        for (i=1;;i++)
        {
            getline
            if ($0 ~ /RETURN/) next
            print
        }

    }
    }' ${input} > ${output}


awk 'BEGIN {cnt=0}
     {cnt+=1
        if($1 ~/TC/) printf("%s\t\tline:%d\n",$0,cnt)
     }' ${output} > ${output}_1
cat ${output}_1 >> ${output}
\rm -f ${output}_1
