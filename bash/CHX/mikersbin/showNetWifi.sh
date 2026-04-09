#!/bin/bash
i=0
while :
 do echo -e "$i \c"
 ip route |grep default
 ip a sh dev eth0 |grep -eeth0 -einet
 ip a sh dev wlan0|grep -ewlan0 -einet
 i=$(expr $i + 1)
 sleep 2
done
