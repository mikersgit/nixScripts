#!/bin/bash

# create new section for bugs diagram (bugs.dot)

# possible port releases
declare -a rels=(5.5 5.6 6.0 6.1 6.0.M 6.1.M 6.2.M 6.3 T)
declare -a relColr=(white white white white pink pink2 pink3 salmon tomato)

rcnt=${#rels[*]}
trb=''
prompt=0

function usage() {
	echo "usage: ${0##*/} -m masterBug -d desc [-t bug,bug,n,bug,...]"
        echo -e "\tThere are ${rcnt} targets. There need to be ${rcnt}"
        echo -e "\tentries after '-t'"
        echo ${rels[*]}
	exit 2
}

while getopts :m:d:t: OPT; do
    case $OPT in
	m)
	MB="$OPTARG"
        ;;d)
	DESC="$OPTARG"
	;;t)
	targs="$OPTARG"
	;;*)
        usage
    esac
done
shift $[ OPTIND - 1 ]

# populate target release bug array
declare -a trb=($(echo ${targs} |
                awk -F"," '{for (i=1;i<=NF;i++) printf("%s ",$i);}'))

# determine if all of the neccessary bug numbers provided
if (( ${#trb[*]} > 0 && ${#trb[*]} < rcnt ))
then
    echo "Only ${#trb[*]} bug numbers provided, ${rcnt} required."
    usage
fi

# prompt for bug numbers if none provided
(( ${#trb[*]} == 0 )) && prompt=1

j=0
for ((i=0;i<${#rels[*]};i++))
{
   ((prompt)) && read -p"${rels[$i]}: " trb[$i]
   # if length of bug number is 1, this means skip that release
   if ((${#trb[$i]} > 1))
   then
    rankstr=${rankstr}${trb[$i]}'; //'${MB}' '${rels[$i]}'\n'
    bg[$j]=${trb[$i]}
    bgClr[$j]=' style=filled,color="'${relColr[$i]}
    ((j+=1))
   fi
}

: ${MB:='MASTER'}
: ${DESC:='BUG Description'}

OUT=${MB}"out"
cat > ${OUT} << eob
//bug group ${MB}
${MB} [color="red"
       label="${MB} ${DESC}"]; 
eob

# build the bug group 
for ((i=0;i<j;i++))
{
    echo ${bg[$i]}' [label="'${bg[$i]}'"'${bgClr[$i]}'"]; //'${MB} >> ${OUT}
}

cat >>${OUT} << eob
//tree ${MB}
eob

# build the tree
for ((i=0;i<j;i++))
{
    echo ${MB}' -> '${bg[$i]}' [color="green"];' >> ${OUT}
}

# output the rank lines for each release that has a bug
echo -e "\n"'// add to release rank subgraph'"\n"${rankstr} >> ${OUT}

echo "Content in ${OUT}"
#cat ${OUT}
