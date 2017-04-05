#!/bin/bash

# Numbered list of source code directories to 
# select from, and change dir to.
#

base='/root/workspace/'
srctp="fmt_0"

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
	alias rsrc="cd ${srcdir}/tools/vdsi"
	alias cli="cd ${srcdir}/ias/modules/cli/src/main/resources/com/ibrix/ias/cli"
	alias clu="cd ${srcdir}/ias/cluster/cfr"
	alias fm="cd ${srcdir}/ias/modules/server/src/main/java/com/ibrix/ias/server/cfr"
	alias doc="cd ${srcdir}/doc/man/man1"
	alias iad="cd ${srcdir}/ias/cpp/common"
	alias intd="cd ${srcdir}/ias/cluster/init.d"
        alias cmds='echo -e "Aliases:\ntp (top) rsrc (ibrcfr) cli (FM api)\nclu (cluster scripts) fm (FM java) doc (man pages)\niad (task struct) intd (init scripts)"'
	pwd
	break
done
