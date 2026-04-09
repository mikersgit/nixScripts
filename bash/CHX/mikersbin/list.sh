#!/usr/bin/bash

# find . |xargs grep -lIi ${1} 2>/dev/null
# echo $#
 find . ! -path \*node_modules\* |
   grep -Ii "${1}" 2>/dev/null

