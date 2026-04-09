#!/bin/bash
# does a find on the build dir, and a dpkg list on the deb package
# then compares the two. Only difference should the the DEBIAN metadata
# files
 find smarten-system_6.1.0.63.24236_all | sed 's/smarten-system_6.1.0.63.24236_all/./' > find.out
dpkg-deb -c  smarten-system_6.1.0.63.wsl.deb | awk '{ print $6 }' > debShort.out
for f in find.out debShort.out
{
	sed 's/\/$//' ${f} | sort  > t
	mv t ${f}
}
#cat debShort.out | sed 's/\/$//' > t ;mv t debShort.out
sdiff -s  find.out debShort.out
