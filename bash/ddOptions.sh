#!/bin/bash

########
# create 10 KB (nominal) files with different characteristics
# (random, sparse, all zeros) using 'dd' command
# compress these files to show the effect compression will have
# show the 'du -kh' and the 'ls -lh' reported sizes
########

# defaults
ddtype="sparse"
content="zero"
size="10kb"
fname="file"

while getopts :t:n:N:z:c:h? OPT; do
    case $OPT in
	t)
	ddtype="$OPTARG"
	;;n)
	fname="$OPTARG"
	;;N)
	fullName="$OPTARG"
	;;z)
	size="$OPTARG"
	;;c)
	content="$OPTARG"
	;;*)
	echo "usage: ${0##*/} [-t full|sparse] [[-n namePrefix]|[-N fullName]] [-z sizeWithUnits<KB,GB,TB>] [-c random|zero] [-h?]"
	exit 2
    esac
done

case ${content} in
    zero) ifd=/dev/zero
	;;
    random) ifd=/dev/urandom
	;;
esac

case ${ddtype} in
        full) btype='F';;
	sparse) btype='S';;
esac

#
# print banner with stars
#
function msg(){
	local cnt=${#1}
	local sline=''
	# create line of stars 4 longer than length of first argument to msg
	for ((c=1;c<=(cnt+4);c++)); { sline=${sline}'*'; }
	#
	# print 'full, zeros' out similar to:
        # *************
        # * full, zeros
        # *************
	#
	echo -e "\n\t${sline}\n\t* ${@}\n\t${sline}\n"
} # end msg()

#
#  this function does the manipulation needed to create files of arbitrary size either
#  sparse or fully populated
#

function getname() {
        if [[ -n ${fullName} ]]
        then
                outFile=${fullName}
        else
                outFile=${fname}${btype}${content}${size}
        fi
} # end getname()

declare -a units=(KB MB   GB      TB)
declare -a multp=(1  1024 1024000 1024000000)

index=99
for ((i=0;i<${#units[*]};i++))
{
	if echo ${size} |grep --silent -i ${units[$i]}
	then
		index=${i}
		break
	fi
}

function fullit() {

    bss="1k"
    cnt=1
    if (( index == 0 ))
        then
	cnt=${num}
    else
	(( cnt = ( num * ${multp[${index}]}) ))
    fi
    dd if=${ifd} of=${outFile} bs=${bss} count=${cnt}

} # end fullit()

function sparseit() {

    u=$(echo ${units[${index}]}| sed 's/B//') # taking the 'B' off uses powers of 2 instead of 10
    bss="1"
    dd if=${ifd} of=${outFile} bs=${bss} count=1 seek=${num}${u}
	
} # end sparseit()

if (( index >=99 || index < 0 ))
then
	echo "Invalid units '$(echo ${size}| tr '[:digit:]' ' ' | awk '{print $1}')'"
	exit 1
fi

num=$(echo ${size} | tr '[:lower:]' '[:upper:]' | sed s/${units[${index}]}//)
# 	echo "Multiplier: ${num}"
# 	echo "Unit: ${units[${index}]}"

getname
msg "${content} ${ddtype} ${size} ${outFile}"

case ${ddtype} in
        full)   fullit;;
	sparse) sparseit;;
esac
