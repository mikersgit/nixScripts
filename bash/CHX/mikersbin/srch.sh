#!/usr/bin/bash

# find . |xargs grep -lIi ${1} 2>/dev/null
# echo $#
 find . |
   grep -v -e node_modules -e packages -e OldTests \
        -e log$ -e sql$ -e csproj -e njsproj -e 'obj/' -e 'build/static'|
   xargs grep -lIi "${1}" 2>/dev/null

