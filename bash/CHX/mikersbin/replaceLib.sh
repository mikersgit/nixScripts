#!/bin/bash
if [[ $# -lt 1 ]];then
        echo "$0 <new lib name>"
        echo "$0 libRIB2.so.1.0-V3"
        exit 1
fi

LIB=$1
if [[ -e $1 ]]; then
        echo "link $1 to libRIB2.so.1.0"
        rm libRIB2.so.1.0
        ln $1 libRIB2.so.1.0
fi
