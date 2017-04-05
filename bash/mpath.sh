#!/bin/bash
MP='/sbin/multipath'
if [[ -x ${MP} ]]
then
    echo "mpath devices"
    ${MP} -l |
    awk '{if($1 ~ /mpath/) print $1" "$3
          if($3 ~ /sd/) printf("\t%s\n",$3)}'
else
    echo "NO mpath devices"
fi
