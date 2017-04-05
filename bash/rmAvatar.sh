#!/bin/bash

LINE='\n************\n'
echo -e "${LINE}Domains${LINE}"
domain list
echo -e "${LINE}Avatar file systems mounted${LINE}"
df -t isis 2>/dev/null
read -p"file system to unmount: " rmFS
umount ${rmFS}
echo
read -p"domain to remove: " rmDM
echo
DEV=$(domain info ${rmDM} | tail -1 | awk '{print $NF}')
domain deactivate ${rmDM}
domain export ${rmDM}
domain delete -fr ${rmDM}
dd if=/dev/zero of=${DEV} bs=4096 count=1000
rm -rf /dev/advfs/${rmDM}
echo -e "${LINE}Remaining Domains${LINE}"
domain list
echo -e "${LINE}Avatar file systems mounted${LINE}"
df -t isis 2>/dev/null
