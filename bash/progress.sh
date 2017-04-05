#!/bin/bash

#script to print progress indicator for number of seconds. It appears
#to be a spinning line
########

function progress () {
        cnt=$1
        declare -a c=('|' '/' '-' '\\' '|' '/' '-' '\\')
        tput civis # invisible cursor
        for ((i=0;i<${cnt};i++))
        {
                if ((j>7))
                then
                        ((j=0))
                else
                        ((j+=1))
                fi
                tput sc # save cursor location
                echo -e "${c[$j]}\c"
                sleep 1
                tput rc # set cursor back to saved location
        }
        tput cnorm # unset any special settings
} # end progress()

progress 20
