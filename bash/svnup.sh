#!/bin/bash
for d in $(find /root/source -maxdepth 5 -name \*fmt_0\*)
{
	#cd ${d%/*}
	cd ${d}
	echo "updating ${d}"
	echo
	svn up
}
