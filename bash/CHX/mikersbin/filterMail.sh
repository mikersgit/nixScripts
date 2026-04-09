#!/bin/bash
#script to parse the rejected emails on gen4.oilgas.center
#creates a file for the date and the unique sender with the subjects
#for that sender

MAILFOLDER=Mail/inbox/cur
OUTPUT=filtered
if [[ $# -gt 0 ]] ; then
        FILTERDATE="$@"
        FILTERDATEstr=$(echo $FILTERDATE|sed 's/[[:space:]]/-/g')
else
        FILTERDATE="$(date '+%b %d')"
        FILTERDATEstr="$(date '+%b-%d')"
fi
mkdir -p $OUTPUT/$FILTERDATEstr
for e in $(ls -l ${MAILFOLDER} |grep "$FILTERDATE"|cut -d" " -f 10)
{
        RECPT="$(grep -e ^Final-R ${MAILFOLDER}/$e |cut -d" " -f 3|sed 's/[[:space:]]//g')"
        RECPT="$(echo $RECPT|sed 's/[[:space:]]//g')"
        grep ^Subject ${MAILFOLDER}/$e |grep -v Undeliv >> $OUTPUT/"${FILTERDATEstr}/${RECPT}"
}
