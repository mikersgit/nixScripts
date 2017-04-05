#!/bin/bash
# create 26 files of a specified size.
# each file contains its name as the only contents, repeated
# sufficient times to reach the desired size.
# the files are named the letters of the English alphabet
####################
firstFile='a'
sz=$1
: ${sz:=8192} # default size is 8K
Flist="b c d e f g h i j k l m n o p q r s t u v w x y z"
\rm -f ${firstFile}
# create file '${firstFile}'
echo "creating ${firstFile} of size ${sz}"
for ((i=1;i<=${sz};i++));{ echo -e "a\c" >> ${firstFile};}
# create additional files by substituting in 'a'
echo "creating ${Flist}"
for l in ${Flist};{ sed "s/a/${l}/g" ${firstFile} > ${l};}
