#!/bin/bash
targ=$(echo $4 | sed 's/user/root/')
echo "ssh -p $3 ${targ}"
DEBUG=""
if [[ ${DEB} = 1 ]]
then
	DEBUG="-vvv"
fi

ssh ${DEBUG} -p $3 ${targ} "tail /var/log/ModbusTCPTrendDaemon.log ; tail /var/log/cloudinterfacedaemon.log"
