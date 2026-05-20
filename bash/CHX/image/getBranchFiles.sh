#!/bin/bash
# an "infile" might look like
###
#current/etc/pcsf/boot_tasks
#current/usr/local/bin/ip_check.sh
#current/usr/local/bin/networkctrl
#current/usr/local/bin/virtual-nic.sh
#current/usr/local/sbin/checkGateway.sh
#current/usr/local/sbin/checkNetworkConfFiles.src
#current/usr/local/sbin/check_services.sh
#current/usr/local/sbin/ifdown
#current/var/spool/cron/crontabs/root
for i in $(< infile)
do
	git show master:${i} >${i##*/}
done


