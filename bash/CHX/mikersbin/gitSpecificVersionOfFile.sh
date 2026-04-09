#!/bin/bash
# supply the git hash of the version of the file you want, then git show outputs to
# stdout
# assumes you are IN the directory that contains the file
HASH=$1
FILE=$2
OUTPUT=${FILE}.$(echo ${HASH}|cut -b 1-8)
git show $HASH:./$FILE > $OUTPUT
ls -l $OUTPUT
