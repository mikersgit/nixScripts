#!/bin/bash
if [[ $# -gt 0 ]]
then
	GMCP=$1
else
	GMCP=/home/exodus/Engine/GenesisMcp.dll
fi
strings -el ${GMCP} |
awk '{if ($1 == "Assembly") {
        printf "%s ", $0
        if (getline > 0 ) {
                print
        }
}}'
