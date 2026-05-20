#!/bin/bash
if [ $# -lt 6 ]
then
	echo "USAGE: ${0##*/} -t $(date "+%Y-%m-%d") -d rootfs/current -o /home/exodus/tmp/deltas-$(date "+%y%j")"
	exit 1
fi

# a ":" following an option on the "getopts" line means the option takes an argument
# the variable ${OPTARG} will contain that value
# use "shift 1" to skip over args other than the automatic OPTARG
# OPTIND is the current index in the list of supplied arguments
#

while getopts "t:d:o:" arg;
do
case ${arg} in 
	t) DATE=${OPTARG}
	    ;;
	d) GitDir=${OPTARG}
	    ;;
	o) OutFile=${OPTARG}
	    ;;
esac
done
# shift passed declared options to anything remaining on command line
# access with ${@}
shift $((OPTIND-1))

cd ${GitDir}

# remove "current" from file names in rootfs output, just confuses later diffs
# renames have the status like "R069" which stands for "rename", so convert those
# to a Delete, and an Add
git log --name-status --summary --since=${DATE} |
awk '{gsub("current/","")
        if ($0 ~ /^M|^D|^A/ && length($1) <=3) {
                print}
        if ($0 ~ /^R/ && length($1) <=4) {
                printf("A\t%s\n",$3)
		printf("D\t%s\n",$2)}
}' > ${OutFile}

sort -uk 2,2 ${OutFile} > ${OutFile}.s
cat ${OutFile}.s

#git log --name-status --summary --since=${DATE} | awk '{ if ($2 ~ /^current/) {sub("current/","");print}}' |tee ${OutFile}
#git log --since=${DATE} --name-only |grep ^current |sort -u|sed 's/current\///' | tee ${OutFile}
#git log --diff-filter=D --summary --since=${DATE} | awk '{ if ($1 == "delete") {sub("current/","");print "D "$4} }' | tee -a ${OutFile}
#git log --name-status --summary --since=${DATE} | awk '{ if ($1 == "D") {sub("current/","");print}}'
