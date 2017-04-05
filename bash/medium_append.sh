#!/bin/bash

# append one char to files in 15 directories each with 
# 100x4M files 10x40M 1x400M

top='/fs_10Segs'
cd ${top}
for d in $(ls -d [0-9]*)
{
	cd $d
	{
	for f in $(ls 4*)
	{
		echo "a" >> ${f}
	}
	} &
	cd ${top}
}
