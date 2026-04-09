#!/bin/bash
#
# show the MAC address for an interface from the kernel, ip stack, and conf file
# they should all be the same
#############################
for i in /sys/class/net/e*
{
        ip a sh dev ${i##*/}|grep link|awk -v ifn=${i##*/} '{print "ip cmd: " ifn " " $2}'
        echo -e "sys:\t${i##*/} $(cat /sys/class/net/${i##*/}/address)"
        echo -e "conf:\t${i##*/} \c"
        grep -e ^[[:space:]]hwaddress -e ^hwaddress /etc/network/interfaces.d/${i##*/}.conf |awk '{print $NF}'
}

