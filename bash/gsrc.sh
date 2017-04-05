#!/bin/bash

# Numbered list of source code directories to 
# select from, and change dir to.
#

base="${HOME}/gwksp"
srctp="likewise-hp"

# if directory is not git entry point, drill down to
# find it
function findTp() {
	local fnd=0
	srcdir=${1}
	while (( ! fnd ))
	do
		if [[ ${srcdir##*/} != ${srctp} ]]
		then
                        if [[ -d ${srcdir}/${srctp} ]]
                        then
                                srcdir=${srcdir}/${srctp}
                                fnd=1
                        else
			        cd ${srcdir}
			        echo -e "Select subdirectory\n"
			        select sdir in $(ls -Fd * | grep /$)
			        do
			        	srcdir=${srcdir}/${sdir%/*}
			        	break
			        done
                        fi
		else
			fnd=1
		fi
	done
} # end findTp

select srcdir in $(ls -Fd ${base}*/* | grep /$)
do
	findTp ${srcdir%/*}
	cd ${srcdir}
	alias tp="cd ${srcdir};echo ${srcdir}"
	alias lwios="cd ${srcdir}/lwio"
	alias servers="cd ${srcdir}/lwio/server"
	alias ibfss="cd ${srcdir}/lwio/server/ibfs"
	alias builds="cd ${srcdir}/build"
	alias bld="cd ${srcdir}/hpbuild;make 2>&1 |tee bld\${RANDOM}.out;cd -"
	alias gb="git branch"
	alias gl="git log"
	alias gpl="git pull"
        alias cmds='echo -e "Aliases:\ntp (top) lwios (lwio) servers (lwio/server)\nibfss (lwio/server/ibfs) builds(build)\ngb (git branch) gl (git log) gpl (git pull) "'
	pwd
	break
done
