#!/bin/bash

sec=10
(( ${#} > 0 )) && sec=${1}

j=1
k=1
while :
do
  ls -l /core* 2>/dev/null
  if (( j == 6 ))
  then
    echo -e "${k}\c"
    j=1
    ((k+=1))
  else
    echo -e ".\c"
    sleep ${sec} 
    ((j+=1))
  fi
done
