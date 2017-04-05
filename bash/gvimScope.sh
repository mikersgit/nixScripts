#!/bin/bash
if (( CSCOPE_WRITABLE ))
then
        ED=/usr/bin/gvim
else
        ED=/usr/bin/gview
fi
if [[ ! -f ${HOME}/.gvimrc ]]
then
        cat > ${HOME}/.gvimrc <<- eog
        set gfn=Courier\ 10\ Pitch\ 18
        set co=120
        set lines=40
        set tagstack
        set tags+=tags;${HOME}
	eog
fi
${ED} --servername CSCOPE-$(hostname) -p4 --remote-silent ${@}
