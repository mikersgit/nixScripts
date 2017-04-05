#!/bin/bash

# take as input 'du /home' output and calcualte the percentage
# each user is consuming of the entire FS.
# print those user consuming more than one percent.
# usage file should be in format "user usage" like would be generated from
#   du -sk mwroberts |awk '{printf("%s %s\n",$2,$1)}'
##

FS='/home'
Total=$(df ${FS}| tail -1 |awk '{print $2}')
InFile='usage.txt'
fmt='%13s %12s %3s\n'

printf "${fmt}" user "1k blks" "percent of total"
printf "${fmt}" ====  =======   ================

sort -rnk2,2 ${InFile} |
while read u d
do
	a=$(echo "(${d}/${Total})*100" |bc -l)
	b=$(printf "%2.0f" $a)
	(( b > 1 )) &&  printf "%13s %12d %3.2f\x25\n" $u $d $a
done

