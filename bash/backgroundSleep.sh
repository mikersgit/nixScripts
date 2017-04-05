#!/bin/bash
#just sleep until someone kills us
((DEBUG)) && set -x
if (($# ==1))
then
    cnt=${1}
else
    cnt=65536
fi
i=0
while ((i<=${cnt}))
do
    ((DEBUG)) && date
    ((DEBUG)) && echo $i
    sleep 2
    ((i+=1))
done
