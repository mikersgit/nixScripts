#!/bin/bash

function doDD() {
    dd conv=notrunc if=${in} of=${out} bs=1 count=${sz} seek=${off}
    ls -lh ${out}
}

# setup array of offsets and sizes to pass to
# dd to write to the file
#            offset
#                 |size
#                 |   |
#                 v   v
declare -a wary=(100 28 5 5 50 50 10 40) # writes not in order,
                                         # but adjacent

#declare -a wary=(0 50 50 50 100 50 150 50) # writes in order, and adjacent
((cnt=${#wary[*]} ))

#in='/dev/zero'
in='/dev/urandom'
out='t'

\rm ${out}
# increment by 2 to grab pairs
# iterate through the array 'wary'
for ((i=0;i<cnt;i+=2))
{
    # from the array get the offset 'i'
    # and the size 'i+1'
    ((j=(i+1)))
    off=${wary[${i}]}
    sz=${wary[${j}]}
    date
    echo "${off}:${sz}"
    doDD
}
