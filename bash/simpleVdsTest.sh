#!/bin/bash

# expects files were created with bin/createSeedFile.sh
#

\rm t
HM='/root'
j=0
for i in a b c d e f g h i j k l m n o p
{
    set -x
    dd conv=notrunc if=${HM}/${i} of=t bs=1 count=3 seek=${j} >/dev/null 2>&1
    set +x
    ((j+=3))
}
ls -l t 
od -c t
