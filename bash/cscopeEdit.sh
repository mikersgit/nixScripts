#!/bin/bash
set -x

# command to invoke either gvim or emacs when this command is set as
# CSCOPE_EDITOR
# default to vim unless emacs set in the environment
: ${VIM:=1}
: ${EMACS:=0}
: ${VI:=0}
: ${CSCOPE_WRITABLE:=0}
((EMACS)) && VIM=0
((VI)) && VIM=0

if ((VIM))
then
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
fi

if ((EMACS))
then
        if emacsclient -n ${@} 2>/dev/null
        then
                :
        else
                emacs ${@} &
        fi
fi

if ((VI))
then
        ED=$(which vim)
        if (( ! CSCOPE_WRITABLE ))
        then
                #ED=/bin/view
                ED="${ED} -R"
        fi
        ${ED} ${@}
fi
