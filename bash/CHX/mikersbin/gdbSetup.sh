#!/bin/bash
function usage(){
	echo "USAGE: ${0##*/}"
	echo "     No options are accepted. The command updates the local apt DB, and then installs GDB"
	exit 1
}

if [ $# -gt 0 ]
then
	usage
fi

if apt list gdb 2>/dev/null | grep -iq gdb
then
	echo "GDB already installed"
	exit 0
fi

echo "Update apt database"
sudo apt update

echo "Install gdb"
sudo apt -y install gdb

