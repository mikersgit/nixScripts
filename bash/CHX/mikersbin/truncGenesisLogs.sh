#!/bin/bash
if [[ $# -gt 0 ]]
then
	GMCP=$1
else
	GMCP=/home/exodus/Engine/GenesisMcp.dll
fi
BuildDate=$(TZ=America/Chicago date +%Y-%m-%d\ %Z\ %H:%M)
GenLogs=(GenesisMcp.log GenesisMcp.startup.log GenesisMcp.error.log)
GenVer=$(strings -el ${GMCP} |
awk '{if ($1 == "Assembly") {
        printf "%s ", $0
        if (getline > 0 ) {
                print
        }
}}')

for L in ${GenLogs[*]}
{
	echo "## ${GenVer}" > ${L}
	echo "## Image built on ${BuildDate}" >> ${L}
}
