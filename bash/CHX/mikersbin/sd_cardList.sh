#!/bin/bash
# list the sdcard images on exodus.center
#
SDCARDurl=http://exodus.center/files/sd_card 
wget -O - -q -np -nd -nH ${SDCARDurl} |
sed -e 's/</ /g' -e 's/>/ /g' |
awk '{if ($3 ~ "^sdcard" )print $3" "$5" "$6}'

