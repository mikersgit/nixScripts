#!/bin/bash

# reseet license on lab clusters that expire

BIN='/usr/local/ibrix/bin'
SSs=$(${BIN}/ibrix_fm -f | awk '$1 !~ /^NAME|^----/ {print $NF}')

# get active fm
${BIN}/ibrix_fm -i

${BIN}/ibrix_fm -m maintenance -A

# remove autopass everywhere
#
for s in ${SSs}
{
        ssh ${s} "rm -rf /usr/local/ibrix/autopass"
}

# restart FM everywhere
#
for s in ${SSs}
{
        ssh ${s} "/etc/init.d/ibrix_fusionmanager restart"
}

# put FMs back in passive
${BIN}/ibrix_fm -m passive -A
