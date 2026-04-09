#!/bin/bash
#
# script to generate getopt command-line options parsing code for bash
# takes getopt option string as an argument and outputs to stdout the
# shell code. eg. genGetOpts.sh Nxv: would have -N -x -v <arg>
#
OptsList=${1}
function splitOpts() {
	echo $OptsList|awk '{slen=length($1)
	for (i=1;i<=slen;i++) {
		str=substr($1,i,1)
		if ( str!=":" )
		{
			nstr=substr($1,(i+1),1)
		    if ( nstr==":" ) {
		    	printf "\t%s) %svar=${OPTARG}\n\t    ;;\n", str, str
			}
			else {
		    	printf "\t%s) \n\t    ;;\n", str
			}
		}	
	}
	}'
}

echo '# a ":" following an option on the "getopts" line means the option takes an argument
# the variable ${OPTARG} will contain that value
# use "shift 1" to skip over args other than the automatic OPTARG
# OPTIND is the current index in the list of supplied arguments
#'
echo '
while getopts "'"${OptsList}"'" arg;
do
case ${arg} in '
	splitOpts
echo 'esac
done
# shift passed declared options to anything remaining on command line
# access with ${@}
shift $((OPTIND-1))'
