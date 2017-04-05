#!/bin/bash

# command to generate a list of branches sorted by the date of the last
# commit to that branch.
#

tmpfl1=$(mktemp)
tmpfl2=$(mktemp)

# if year is given on command line, then filter for branches last
# updated in that year.
#
opYr=${1}
: ${opYr:=0}

#
# for all branches
#
for b in $(git branch -a       |
            grep -v -eHEAD -e\*|
            awk '{print $1}'   |
            grep -e^topic -e^remote)
{
    # get the date
    #
    dt=$(git log --date=short --pretty=format:%cd -n 1 ${b})

    # get the year from the date
    #
    yr=${dt%%-*}

    # if the year and the year to be filtered match, or if no filter
    # given, output the date and the branch name
    #
    if (( opYr == yr || opYr==0 ))
    then
        br=$(echo ${b}|sed 's!remotes/origin/!!')
        (( ${#dt} > 0 )) && echo -e "${dt}  ${br}" >> ${tmpfl1}
    fi
}

# sort the list ascending by year then month then day
#
sort -k1,4n -k6,7n -k9,10n ${tmpfl1} > ${tmpfl2}

# Insert year headers in the list, then output the list
#
awk 'BEGIN {yr=0;prevyr=0;cnt=0}
    {yr=substr($1,1,4)
        cnt++
        if (yr!=prevyr) {
        printf("\n\t********\n\t* %s *\n\t********\n",yr)
        prevyr=yr
        }
    print}
    END {print "Number of branches: "cnt}' ${tmpfl2}

rm -f ${tmpfl2} ${tmpfl1}
#git log --date=short --pretty=format:%cd -n 1 615a2243
