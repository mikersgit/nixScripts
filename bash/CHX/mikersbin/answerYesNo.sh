#!/bin/bash
read -p "answer? [n]|y" ans
if [[ $ans = "y" || $ans = "Y" ]]
then
   echo "$ans"
else
   echo "default $ans"
fi
