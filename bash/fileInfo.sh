#!/bin/bash

fl=${2}
dir=${1}

cd ${dir}
# print "S"ize "A"time "M"time "C"time
echo '*** stat and cksum info ***'
stat --printf="S %s\nA %x\nM %y\nC %z\n" ${fl}
cksum ${fl}
echo -e '\n*** ACL info ***'
getfacl ${fl}
echo -e '*** XATTR info ***'
getfattr -d -m ".*" ${fl}
