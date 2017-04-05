#!/bin/bash
BIN='/usr/local/ibrix/bin'
FS=$1
echo "Segment ownership for file system: ${FS}"
echo -e "SEG    NODE\c"
${BIN}/ibrix_fs -i -f ${FS} | awk 'BEGIN {s=0}
{if($1 ~ /SEGMENT/) {
    s=1;getline;getline
}
if($1 ~ /HOST_NAME/) s=0 
if (s) printf("%s      %s\n",$1,$2)
}' | sort -u|sort -k2,2

