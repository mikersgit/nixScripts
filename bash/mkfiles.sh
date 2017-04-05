#!/bin/bash

# variables
hst='mwr1-1'
shdir='/fs1_41/d1/d2'
rhst='mwr1-2'
rip='10.30.237.158'
rscr='/root/mkfiles.sh'

# in shared dir, create files with hostname and random number
#
cd ${shdir}
for ((j=1;j<6;j++)); { touch fl$(hostname)${RANDOM}; }

# execute script on remote that creates files there
# then sleep 10 seconds
ssh ${rip} ${rscr}
sleep 10

# remove files created by this host
rm -f ${shdir}/fl${hst}*
# remove files created by remote host
ssh ${rip} "rm -f ${shdir}/fl${rhst}*"

# script on remote looks like
#
# cat ~/mkfiles.sh
#cd /fs1_41/d1/d2
#for ((j=1;j<6;j++)); { touch fl$(hostname)${RANDOM}; }
