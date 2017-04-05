#!/bin/bash

# normal redirection
#
echo "stdout" >&1
echo "stderr" >&2
# combine stderr and stdout on stdout File Descriptor
#
echo "out and err to stdout" 2>&1

# "sticky" redirection to a log file of stdout
#
exec 3>&1 > stdout.log

# now these echos will go to the logfile instead of screen
#
echo "Last 10 files in listing"
ls | tail -10
echo "stdout log $(date)"

# reDirect of known fail command goes to log file
# not the screen
# 
ls NonExistentFile 2>&1

# Quick! undo the magic
# 1. get stdout back
# 2. close FD #3
exec 1>&3
exec 3>&-

exec 3>&1 # remember previous stdout state

# stdout and stderr to log file
#
exec 1>stdouterr.log 2>&1

# the echo and error message will go to log file
#
echo "second method"
ls NonExistentFile 

# put it all back
exec 1>&3
exec 3>&-

# now we see "normal" stdout behavior
echo "normal output: files updated"
ls -lrt  |tail -5

# less common, but works
# to get stdout and stderr going to a file
#    Note the direction of '<' v. '>'
#
\rm -f logit
echo "un-common redirection $(date)" >> logit 2<&1
ls Nothing >> logit 2<&1

echo "common redirection $(date)" >> logit 2>&1
ls Nothing >> logit 2>&1
