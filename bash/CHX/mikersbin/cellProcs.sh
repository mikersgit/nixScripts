#!/bin/bash
PROCS=("-e qual" "-e qcom" "-e ril" "-e rmt" "-e mss" "-e netmgr" "-e mcm" "-e cell" "-e gps")
ps -ef |grep ${PROCS[@]} |grep -v -e grep -e ${0}
