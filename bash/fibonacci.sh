#!/bin/bash

# calculate series to N iterations
# N defaults to 10 (command line)

if (( $# <= 0 ))
then
  n=10
else
  n=${1}
fi

p0=0
p1=1
echo -e "$p0,$p1\c"

for ((c=1;c<=n;c++))
{
	((su=p0+p1))
	if (( ${#p1} > ${#su} ))
	then
		printf "\n  N: %d too big ans len: %d\n" $c ${#p1}
		printf "N-1: %llu\n  N: %llu\n" ${p1} ${su}
		exit 1
	fi
	printf ",%llu" $su
	p0=${p1}
	p1=${su}
}
echo
