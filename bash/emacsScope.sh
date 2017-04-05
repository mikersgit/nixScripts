#!/bin/bash
if emacsclient -n ${@} 2>/dev/null
then
        :
else
        emacs ${@} &
fi
