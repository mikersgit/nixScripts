#!/bin/bash

#
# Script to list the changes between now and N days ago, sorted by user
#

# example cron job
# 0 5 * * * ~/bin/turmoil.sh -R  https://svn01.atlanta.hp.com/local/swd-usd-eng/trunk/fmt_0 -o /root/data/turmoil

function usage() {
	echo "usage: ${1##*/} [-u \"users\"] [-d <number of days>] [-R <repository URL>] [-o outdir] [-?h]"
	echo -e "\t-u user\tUsername(s) for whom to display changes."
	echo -e "\t\tQuoted space separated list of users. Default all users."
	echo -e "\t-d days\tNumber of days of changes to show. Default 1 day."
	echo -e "\t-R URL\tURL of repository from which to get log.\n\t\tDefault working copy."
	echo -e "\t-o outdir\tDirectory to which to write Y_MO_DY file."
	echo -e "\t-?|h\tusage"
	exit 2

} # end usage()

#
# defaults
#

# Source URL
# use working copy base if it exists, else default to trunk
# can be overridden by command line option
if [[ -d .svn ]]
then
    sURL=$(grep https: .svn/entries|head -1)
else
    sURL='https://svn01.atlanta.hp.com/local/swd-usd-eng/trunk/fmt_0'
fi

# unsorted log output
rawturmoil="${HOME}/turmoil"

# default output to stdout
outCmd='cat -'

# Number of days in past to look for changes
days=1
userStr='ALL'

while getopts :u:d:R:o:?h OPT; do
    case $OPT in
	u|+u)
	users="$OPTARG"
	userStr="${users}"
	;;d|+d)
	days="$OPTARG"
	;;R|+R)
	sURL="$OPTARG"
	;;o|+o)
	outdir="$OPTARG"
	outPath="${outdir}/$(date '+%Y_%m_%d')"
	outCmd="tee -a ${outPath}"
	\rm -f ${outPath}
	;;*)
	usage ${0}
    esac
done
shift $[ OPTIND - 1 ]

# number of days in past to get logs (default 1 day)
dstr=$(date -d "${days} day ago" +'%Y%m%dT%H%M')

# what changed
svn log -vr {${dstr}}:HEAD ${sURL} |
    awk '$0 ~ /^r[[:digit:]]|([[:space:]][MDAR][[:space:]]\/)/ {print}' > ${rawturmoil}

# Sort changes by user, either all (default) or command line specified user
: ${users:=$(grep \@ ${rawturmoil} | awk '{print $3}' | sort -u )}

# what did they change
str='###############################'

# temp files to store the report until output
headerFile=$(mktemp)
dataFile=$(mktemp)
echo -e "\n${str}" > ${headerFile}
echo -e "Changes since ${dstr}\nFor repo: ${sURL}\nFor users: ${userStr}" >> ${headerFile}

# Display changes for each user with a per user summary as the last line
for i in ${users}
{
	echo -e "\n${str}\n## ${i}\n${str}\n" 
	awk -v w=${i} 'BEGIN {fnd=0;rcnt=0;fcnt=0}
    	{if($1 ~ /r[[:digit:]]/)
		{
	 	if(index($0,w))
	 	{
                        rcnt+=1
	 		fnd=1
	 	}
	 	else
			fnd=0
		}
		if (fnd == 1)
		{
                        fcnt+=1
			print
		}
	}
        END {printf("Commits: %d\tFiles: %d\n",rcnt,(fcnt-rcnt))}' ${rawturmoil} 
} > ${dataFile}

# per run summary
echo "      Total Authors: $(grep '^\#' ${dataFile} | grep '@hp' | wc -l)" >> ${headerFile}
echo "      Total Commits: $(grep '^r[[:digit:]]' ${dataFile} | wc -l)" >> ${headerFile}
echo "Total Files changed: $(grep '^[[:space:]]*[MDAR]' ${dataFile} | wc -l)" >> ${headerFile}
echo -e "${str}\n" >> ${headerFile}

cat ${headerFile} | ${outCmd}
cat ${dataFile} | ${outCmd}
rm -f ${dataFile} ${headerFile}
