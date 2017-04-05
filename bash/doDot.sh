#!/bin/bash
map=''
out='png'
if [[ $1 = "html" ]]
then
    out='svg'
    map="-Tcmapx -o${2%.*}.map"
    shift 1
fi
fl=$1
ot=${fl%.*}".${out}"
#dot $fl -Tpng -O
dot $fl ${map} -T${out} -o ${ot}
