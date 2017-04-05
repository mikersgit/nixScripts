#!/bin/bash

#
# stop watch
#
function sw() {
	dstr=+"%H:%M:%S:%N"
	case $1 in
	start) echo "START:: $(date ${dstr})"
	;;
	stop) echo "STOP:: $(date ${dstr})"
	;;
	esac
}

#
# output divider
#
function outstr() {
	l='#####################################'
	echo -e "\n\t${l}\n\t## ${@}\n\t${l}\n"
}

#
# call rsync
#
function dorsync() {
set -x
	export RSYNC_PASSWORD=hpinvent
	rsrc=${1}
	rtarg=${2}
	sw start

	if ((DEBUG))
	then
		debug="-vv \
			--log-format=\"%t,<%p>,%i,%n%L\" \
			--stats \
			--itemize-changes "
	else
		debug=''
	fi

		#-WRaAX \
		#--exclude 'dir0*/***' \
	rsync   --port=9559 \
		${debug} \
		--hard-links \
		-WRlptgoDdAX \
		--recursive \
		--include 'dir0/' \
		--include 'dir0/file0' \
		--exclude '*' \
		--modify-window=1 \
		--bwlimit=0 \
		--delete-during \
		--inplace \
		${rsrc} ${tip}::${tmod}
	sw stop
set +x
}

tip=10.30.244.126
tmod='fs1_t'
tfs='/fs1_t'
fs='/fs1'
pdir='dtest'
dir='dir0'

cd ${fs}

outstr "rsync" 
dorsync "${fs}/./${pdir}/dir0"
