#!/bin/bash

function msg(){
        local cnt=${#1}
        local sline=''
        local c
        # create line of stars 4 longer than length of first argument to msg
        for ((c=1;c<=(cnt+4);c++)); { sline=${sline}'*'; }
                 echo -e "\n\t${sline}\n\t* ${@}\n\t${sline}\n"
} # end msg()

msg 'EXPERIMENTAL!\n\tExit now if this is NOT what you expected.'
