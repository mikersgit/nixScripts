#!/bin/bash

# exodus.center is in Mountain Timezone, so set TZ accordingly
export TZ="America/Denver"
mtz=$(date "+%Z")
now=$(date "+%H%M")
# 6 = Saturday
# 0 = Sunday
dow=$(date "+%w")

# Excodus.center only builds M->F, so if this is called on a Monday before noon,
# then the previous build date is Friday. Also accomadate if the script is run
# on a Sunday, to go back to Friday. All others go back one day.
function prevBuildDate() {
	case $dow in
		1) dago=3;;
		0) dago=2;;
		*) dago=1;;
	esac

	yr=$(date --date="${dago} day ago" +%Y)
	mo=$(date --date="${dago} day ago" +%m)
	dy=$(date --date="${dago} day ago" +%d)
}

function usage() {
	echo "USAGE: ${0##*/} [help |<year> <month> <day> <time>]"
	echo " # pull noon build from today"
	echo " eg. ${0##*/} $(date +%Y) $(date +%m) $(date +%d) 1200"
	echo " without any args, most recent build is pulled"
	exit 1
}

if [ $# -eq 1 ]
then
	usage
fi

if [ $# -gt 1 ]
then
	yr=$1
	mo=$2
	dy=$3
	tm=$4
else
	# should go back one day if it is earlier than 1200 today
	#date --date="1 day ago" "+%Y %m %d"
	#  dcmd='date --date="1 day ago" +"%d"'
	# yr=$(eval ${dcmd})
	yr=$(date +%Y)
	mo=$(date +%m)
	dy=$(date +%d)
	# need to test if it is Sat or Sun and call "prevBuildDate" regardless of current time
	if [ ${now} -lt 1200 ] || ( [ $dow = 0 ] || [ $dow = 6 ] )
	then
		prevBuildDate
		tm=1800
	elif [ ${now} -le 1800 ]
	then
		tm=1200
	else
		tm=1800
	fi
fi
WWWhost=exodus.center
WWWbase="http://${WWWhost}/files/capps"
WWWdatePath="$yr/${yr}-${mo}/${yr}-${mo}-${dy}-${tm}"
WWWurl=${WWWbase}/${WWWdatePath}
#WWWdirs=(app lib Databases/Admin Databases/Datalog Databases/DirectCSVlogger Databases/Genesis Databases/RIB2)
WWWdirs=(app lib)

verifyConnection() {
	ret=$(ping -q -c 2 -i 2 $1 &>/dev/null ;echo $?)
	if [ $ret -gt 0 ];then
		echo "Cannot reach $1"
		echo "Make sure you have a default gateway"
		echo "To check: $ ip r"
		echo "To add gateway: $ ip r add default via 192.168.0.1"
		echo "Or add direct entries \"<IP> <hostname>\" in /etc/hosts"
		exit 1
	fi
}

verifyConnection ${WWWhost}

echo "Date to retrieve: ${yr}-${mo}-${dy}:${tm} ${mtz}"
dwnld="excmain"
if [ -e ${dwnld} ]
then
	rm -rf ${dwnld}
fi
mkdir -p ${dwnld}
cd ${dwnld}
here=${PWD}
ls -lR $here

for d in ${WWWdirs[@]}
{
	mkdir -p ${d}
	cd ${d}
	wget -qr -nd -nH -np -R dir.info -A *exe,*sh,lib*0,*csv,*info,*sql,*sqlite ${WWWurl}/${d}/
	ls -l ${here}/${d}
	cd - > /dev/null
}
