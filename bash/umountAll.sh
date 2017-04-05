#!/bin/bash

df -t ibrix
FSs=$(df -t ibrix| grep -v ^Filesystem | awk '{printf("%s ",$1)}')

for f in ${FSs}
{
	ibrix_umount -f ${f}
}

df -t ibrix
