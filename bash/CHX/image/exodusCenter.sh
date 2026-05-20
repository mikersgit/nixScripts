#!/bin/bash
# list the files images on exodus.center
#
ECENTERhost=exodus.center
ECENTERurl=http://${ECENTERhost}/files/
dirs=(sd_card iotbone genesis sd_card/release genesis/V5.1.0%20pre-release genesis/v5.0.0_pre-release)
sfxs=(xz img mbn)

USAGE() {
	echo "USAGE: ${0##*/} -L|-G <web dir> -t <file>|[<suffix>]"
	echo "eg: ${0##*/} -L genesis -t xz"
	echo "eg: ${0##*/} -G genesis -t smarten-5.0.0.41.4667.tar.xz"
	echo "URL: ${ECENTERurl}"
	echo "Web Dirs: ${dirs[@]}"
	echo "Suffixes: ${sfxs[@]}"
	exit
} # end USAGE()

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

LIST() {
	wget -O - -q -np -nd -nH ${ECENTERurl}${DIR} |
	sed -e 's/</ /g' -e 's/>/ /g' |
	awk -v SFX=${SFX} '{if ( $3 ~ ".*"SFX"$" ) print $3" "$5" "$6}'
} # end LIST()

GET() {
	if [ -e ${FILE} ] ; then
		echo "${FILE} already exists."
		ls -l ${FILE}
		exit 1
	fi
	echo "Retrieving  ${ECENTERurl}${DIR}/${FILE}"
	wget -qr -np -nd -nH -A ${FILE} ${ECENTERurl}${DIR}/ &
	pid=$!

	while :
	do
		sleep 5
		JPID=$(jobs -pr)
		if [ x${pid} = x${JPID} ]; then
			tput el;tput sc;printf %s"	"%s $(ls -l ${FILE}| awk '{print $5" "$9}') ;tput rc
		else
			tput el;tput sc;printf %s"	"%s $(ls -l ${FILE}| awk '{print $5" "$9}') ;tput rc
			echo
			echo "Completed"
			break
		fi
	done
} # end GET()

[ ${#} -lt 1 ] && USAGE

# a ":" following an option on the "getopts" line means the option takes an argument
# the variable ${OPTARG} will contain that value
# use "shift 1" to skip over args other than the automatic OPTARG
#

while getopts "L:G:t:" arg;
do
case ${arg} in 
	L)
	    [ ${#} -lt 2 ] && USAGE
	    DIR=${OPTARG}
	    MODE="list"
	    ;;
	G)
	    [ ${#} -lt 3 ] && USAGE
	    DIR=${OPTARG}
	    MODE="get"
	    ;;
	t)
	    targ=${OPTARG}
	    ;;
esac
done

verifyConnection ${ECENTERhost}

case ${MODE} in
	"list")
		SFX=${targ}
		LIST ;;
	"get")
		FILE=${targ}
		GET ;;
esac
