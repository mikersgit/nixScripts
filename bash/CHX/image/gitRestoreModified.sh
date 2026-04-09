#!/bin/bash
#
# First, remove any ADDED files using git clean then
# using short form of status, "M path/to/file", restore 
# modified files.
# 
# can also use 'git reset --hard'

git clean -fd
git status -s |while read s f 
	do
		git restore $f
	done

