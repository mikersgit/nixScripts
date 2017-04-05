#!/bin/bash
	read -p "Blade number: " bn
	read -p "Cluster number: " cn
declare -a webVars=(bn cn uip1 gtwy1 clip1 uip2 gtwy2 clip2 range)
j=0
for v in $( curl -s http://vdures.usa.hp.com/couplets/ftc-unem-clus${bn}-${cn}.htm |
 awk 'function stripit(STRING) {
	split(STRING,ary,">")
	sub("</td","",ary[2])
	return ary[2]
	}
	{
	if ($0 ~ /Blade:|Cluster:/) {
	getline;getline
	outstr=stripit($0)
	print outstr }
	if ($0 ~ /User GTW|User IP|Cluster IP|User Network/) {
	getline
	outstr=stripit($0)
	print outstr }
}')
{
	webVals[$j]=${v}
	echo ${webVars[$j]}" "${webVals[$j]}
	((j+=1))
}
	echo ${webVals[*]}
