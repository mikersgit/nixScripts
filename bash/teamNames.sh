#!/bin/bash
while read line
do
   echo ${line} | md5sum | tr -d "[[:alpha:]]" |
awk '{sub("0",substr($1,2,1),$1);print substr($1,0,4)}'
#awk '{print substr($1,0,4)}'
done < teamNames.txt
