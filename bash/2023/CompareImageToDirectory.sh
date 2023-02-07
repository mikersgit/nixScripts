#!/bin/bash

if [[ $# < 2 ]]
then
  echo "${0} <imageDir> <buildDir>"
  exit 1
fi

ImageDir="${1}"
Folder="${2}"
rsync --exclude=.bash_history -xrplcvn ${ImageDir}/ ${Folder}/
