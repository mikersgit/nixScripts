#!/bin/sh
#
# in a VBA macro calculate the offset from the beginning column of a
# selection to the column to be filtered
startLetter=$1
offset=$2
declare -a ary=( a b c d e f g h i j k l m n o p q r s t u v w x y z aa ab ac ad ae af ag ah ai aj ak)
for ((i=0;i<=100;i++))
{
    if [[ ${ary[$i]} = $1 ]]
    then
        break
    fi
}
echo "start: "${ary[$i]}
((j=i+(offset-1) ))
echo "end: "${ary[$j]}
echo ${offset}
