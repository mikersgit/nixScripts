#!/bin/bash

# command to return comma delimeted list of pids for
# consumption by commands like 'ps' and 'top'
# Ex. ps -o args -p $(commaPids.sh sshd)
###############

pgrep "${@}" | 
awk 'BEGIN { f=0 } 
     {
        if (f==0) {
                f=1
                printf("%s",$1)
        }
        else
                printf(",%s",$1)
     }'
