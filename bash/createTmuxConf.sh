#!/bin/bash

# Script to create tmux configuration file
#

#
# common settings, check the websites for more info on the config
#
header='
# http://tmux.sourceforge.net/
# http://brainscraps.wikia.com/wiki/Extreme_Multitasking_with_tmux_and_PuTTY\n
# set-option -g status off\n
set-option -s escape-time 2\n
set-option -g set-titles on\n
set-window-option -g automatic-rename on\n
set-window-option -g mode-keys vi\n
set-window-option -g alternate-screen on\n
set-window-option -g aggressive-resize on\n
set-window-option -g automatic-rename on\n
set-option -g history-limit 10000\n
set-option -g prefix C-z\n
unbind-key C-b\n
'

#
# query the user for the session names they wish to have, and
# how many windows within each session they want.
# either 'QQ' or empty ends the query and writes out the conf file
#
DONE=0
i=0
OUT="tmux.conf_"${RANDOM}
while ((! DONE))
do
        read -p"session name (QQ to exit): " SES
        : ${SES:=QQ}
        if [[ ${SES} != "QQ" ]] 
        then
                wNum=0
                ses_ary[${i}]="new-session -d -s ${SES}"
                read -p"     number of windows for session ->${SES}: " wNum
                : ${wNum:=0}
                ses_win_ary[${i}]=${wNum}
                ((i+=1))
        else
                DONE=1
        fi
done

# if no session names were given, exit
((i==0)) && exit 1

# begin building the config file from inputs
echo -e ${header} > ${OUT}

# for each session name, create the window commands if any
#
for ((j=0;j<i;j++))
{
        echo ${ses_ary[${j}]} >> ${OUT}
        for ((k=0;k<${ses_win_ary[${j}]};k++))
        {
                echo "neww -t w${k}" >> ${OUT}
        }
}

echo -e "\nWhen you are satisfied with the conf file ${OUT}"
echo -e "move it to ${HOME}/.tmux.conf\n\n"
echo -e "Then run the tmux command ($(which tmux))."
echo -e "And check for sessions 'tmux list-sessions'"
