#!/bin/bash
cd ${@}
export PS1="[\h $(echo ${PWD} | awk '{c=split($0,a,"/");printf("%s/%s\n",a[c-1],a[c])}')]\$ "
