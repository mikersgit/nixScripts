#!/bin/bash
#Assumes that "git log --since=03-14-2023 --name-only |grep ^current |sort -u|sed 's/current\///' > ~exodus/tmp/deltas.txt" has been run
#for f in $(< /home/exodus/tmp/deltas.txt); { d="/${f%/*}";scp -P 2730 ${f} root@172.28.4.63:${d}/. ; }
for f in $(< /home/exodus/tmp/deltas.txt)
{
	d="/${f%/*}"
	echo "cp -a ${f} /mnt/img/${f}"
	cp -a ${f} /mnt/img/${f}
}
