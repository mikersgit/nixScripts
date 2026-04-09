#!/bin/bash
#set -x
TARFILE="/home/exodus/mwrGen.tar"

function toggle()
{
	WAIT=20
	action=${1}
	sudo monit ${action} all ; sleep ${WAIT} ; sudo monit summary
}

date
ls -l ${TARFILE}
echo -e "\t===== shutdown smarten =====\n"

toggle stop

echo -e "\t===== extract smarten dev tar in Engine =====\n"

cd ~/Engine
echo -e "\t===== ${PWD} =====\n"

tar -xvf ${TARFILE}

echo -e "\t===== start smarten =====\n"

toggle start
