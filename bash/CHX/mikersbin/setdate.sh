#!/bin/bash
if (( $# < 2 ))
then
    echo "USAGE: ${0} $(date +%Y-%m-%d) $(date +%H:%M)"
else
	date --set ${1}
	date --set ${2}
fi
