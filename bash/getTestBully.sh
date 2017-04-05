#!/bin/bash

# script to pull cifs AI regression results from the AI server
# you can supply a relative day to pull like 'yesterday' on the
# command line (yesterday is the default). html and csv files are
# generated with the date and job name.
####

hst='http://e2s12.vpi.hp.com/results'
topdir='cifs_test_engineer'
URL="${hst}/${topdir}"
patrn='cifs_regressions'
rsFl='Cifs_Regression_Result'
rsCsv='result.csv'
outdir='.'
#outdir='/cygdrive/c/Users/mwroberts/'

# 'when' can be like "today", "2days-ago", "today-2days", "yesterday"
if (( $# ))
then
    when="${1}"
else
    when='yesterday'
fi

dt=$(date -d ${when} +%d-%b-%Y)
echo "Date: ${dt}"
# list the cifs directories on the AI server that match the requested date
#
function lsdir() {
curl  ${URL}/  2>/dev/null |
      grep -e ${patrn}     |
      grep ${dt}           |
      cut -d " " -f5       |
      cut -d ">" -f1       |
      sed -e 's!href="!!' -e 's!/"!!'
}

#
# if a requested file comes back '404 Not Found' then delete
# the stub
#
function checkNtFnd() {
    local fl=${1}
    local ntFnd="404 Not Found"
    for t in csv html
    {
        if grep -q "${ntFnd}" ${fl}.${t}; then rm -f ${fl}.${t};fi
    }
}

# for the current month list the html files from earliest to most
# recent
function listHtmlfiles() {
   ls *$(date '+%b')*html |sort -nk1,2
}

# for each of the cifs test directories get the results file
# and store it locally named like Date_JobName.html
# and the CSV file Date_JobName.csv
#
for i in $(lsdir)
{
        outFl="${outdir}/${dt}_${i}"
        curl -o ${outFl}.html ${URL}/${i}/${rsFl} 2>/dev/null
        curl -o ${outFl}.csv ${URL}/${i}/${rsCsv} 2>/dev/null
        checkNtFnd ${outFl}
}

listHtmlfiles
