#!/bin/bash

# diff files between two clones
# it is assumed that the path from likewise down is the same

if (( ${#} >= 1 ))
then fl=${1}
else echo "Need a file to diff."; exit 1
fi

here=${PWD}
base=${HOME}/gwksp
brnch="nt/likewise-hp"

if [[ -z ${nt} ]]
then if cd ${base}/${brnch}
     then
	nt=$PWD ; cd ${here}
     fi
fi

frmPth="${nt}${PWD#*/likewise-hp}"
echo -e "From: ${frmPth}/${fl}\n  To: ${PWD}/${fl}"
diff ${frmPth}/${fl} ${fl}
