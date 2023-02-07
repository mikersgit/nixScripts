#!/bin/bash
st=$1
ed=$2
if [[ "x${3}" = "x" ]]
then
   prefix='172.28.4'
else
   prefix=${3}
fi
if [[ $# < 2 ]]
then
    echo "USAGE: ${0} <start range> <end range> [subnet prefix]"
    echo "  eg. ${0} 60 70 ${prefix}"
    echo " that will find the available IPs in the range ${prefix}.[60-70]"
    exit 1
fi
echo "available IPs"
echo "${prefix}.[${st}-${ed}]"
echo "============="
for i in $(seq ${st} ${ed})
{
	ip=${prefix}.${i}
	if ping -w 3000 -n 1 ${ip} | grep -q 'unreachable'
	then
		echo -e "${n}${ip}"
		n=""
	else
		echo -ne "+\c"
		n="\n"
	fi
}
