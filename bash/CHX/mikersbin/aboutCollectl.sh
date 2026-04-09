#!/bin/bash

####
# initialize file and directory locations
# command locations
##############################
function init() {
  getColPkgName
  historyDir="/var/collectl-log"
  confFile="/etc/collectl.conf"
  pidFile="/var/run/collectl.pid"
  LSCMD="ls -hl ${historyDir}/*gz"
  HTOP="/usr/bin/htop"
  if [ $UID -gt 0 ]
  then
     SUDO=/usr/bin/sudo
  else
     SUDO=""
  fi
}

####
# sum up the output from "ls -l output"
# assumes size is in field 5
##############################
function addDir() {
  awk '{tot+=$5}
     END {print "Total size: "(tot/1000000)"MB"}'
}

function getColPkgName() {
 pkgName=$(dpkg -l |grep collectl |awk '{print $2}')
 fileList="/var/lib/dpkg/info/${pkgName}.list"
 if [ ! -e ${fileList} ]
 then
     echo "No collectl installed"
     exit
 fi

}

init

echo -e "\t## Installation \c"
ls -l $(cat ${fileList})|addDir
echo

echo -e "\t## History files \c"
$LSCMD|addDir
echo -e "\t## History files ## "
$LSCMD

echo -e "\n\t## collectl service status ##"

${SUDO} service collectl status

echo -e "\n\t## collectl daemon command $confFile ##"
grep -v -e ^$ -e ^# $confFile |grep Daemon

echo -e "\n\t## root filesystem usage ##"
df -h /
echo

read -p "Enter to continue with live 'htop' info, 'Q' to quit " ans
if [[ $ans =~ [q,Q] ]]
then
   exit 0
fi
$HTOP -p $(cat ${pidFile})
