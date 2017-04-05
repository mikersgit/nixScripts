#!/bin/bash

#
# crafted link to submit bug with fields pre-populated
# Michael Roberts 21-Feb-2016
#

# modified URL from Windows that worked
# https://bugzilla.houston.hpecorp.net:1181/bugzilla/enter_bug.cgi
# ?assigned_to=michael.roberts%40hpe.com
# &attachurl=&blocked=&bug_file_loc=http%3A%2F%2F
# &bug_severity=normal
# &bug_status=NEW
# &cc=matthew.glover%40hpe.com
# &cf_defecttype=Defect
# &cf_foundby=Build
# &comment=
# &component=*Unknown%20(Triage)-SMB
# &contenttypeentry=&contenttypemethod=autodetect&contenttypeselection=text%2Fplain&data=&deadline=&dependson=&description=&estimated_time=0.0
# &form_name=enter_bug&keywords=&maketemplate=Remember%20values%20as%20bookmarkable%20template
# &op_sys=Linux
# &priority=P2
# &product=Protocols-SMB
# &qa_contact=
# &rep_platform=PC
# &short_desc=Build%20error
# &target_milestone=future
# &version=Avitus

product=''
component=''
severity=''
version=''
probability=''
cclist=''
declare -a cclistIN
summary=''

function usage() {
	echo "usage: ${1} [-p product -c component] [-s severity]"
        echo -e "\t[-v versionFound] [-P probability] [-C cclist]"
        echo -e "\t[-S summary] [-?h]"
        echo -e "Prompts for all needed values will be presented if no options \c "
        echo "given."
        echo -e "\t -p product     Product name (must also specify -c option)"
        echo -e "\t -c component   Component within that product (must also"
        echo -e "\t\t\tspecify -p option"
        echo -e "\t -s severity    blocker, critical, major"
        echo -e "\t -v version     Version in which bug was found"
        echo -e "\t -P probability High, Medium, Low"
        echo -e "\t -C cclist      Quoted, space separated list of email addresses"
        echo -e "\t -S summary     Quoted one liner of bug"
        exit 2
} # end usage()

while getopts :p:c:s:v:P:C:S:?h OPT; do
    case $OPT in
	p)
	product="$(echo $OPTARG | sed 's/[[:space:]]/%20/g')"
	;;c)
	component="$(echo $OPTARG | sed 's/[[:space:]]/%20/g')"
	;;s)
	severity="$OPTARG"
	;;v)
	version="$OPTARG"
	;;P)
	probability="$OPTARG"
	;;C)
	declare -a cclistIN=($(echo $OPTARG |
            sed 's/@/%40/g'))
	;;S)
	summary="$(echo $OPTARG | sed 's/[[:space:]]/%20/g')"
	;;?)
	usage ${0##*/}
	;;h)
	usage ${0##*/}
	;;*)
	usage ${0##*/}
	exit 2
    esac
done
shift $[ OPTIND - 1 ]

#
# compSuffix and products must maintain the same ordering. The compSuffix
# is the ending of the 'Triage' component for each product.
#
declare -a compSuffix=(Quotas NDMP AAUM HTTP NFS SMB Platform FS%20Management%Platform Avatar AV Snapshots ADE FS%20Management HTTP%20DataPath)
declare -a products=(Quotas Protocols-NDMP Protocols-AAUM Protocols-HTTP Protocols-NFS Protocols-SMB Platform%20Software PML%20Core%20Services AvatarFS AntiVirus Snapshots ADE FileSystem%20Management%20%28IAS%29 Protocols-HTTP-DataPath)

#
# severity of bug found
# Prompt if not set on command-line
#
if ((!${#severity}))
then
   declare -a severities=(blocker critical major)
   for ((i=0;i<${#severities[*]};i++))
   {
       echo ${i} ${severities[${i}]}
   }
   read -p"Number of severity: " p
   severity=${severities[${p}]}
fi

#
# Version in which bug was found
# Prompt if not set on command-line
#
if ((!${#version}))
then
   declare -a versions=(Aurora Avitus)
   for ((i=0;i<${#versions[*]};i++))
   {
       echo ${i} ${versions[${i}]}
   }
   read -p"Number of version: " p
   version=${versions[${p}]}
fi

#
# Bedrock probability
# Prompt if not set on command-line
#
if ((!${#probability}))
then
   declare -a probabilities=(High Medium Low)
   for ((i=0;i<${#probabilities[*]};i++))
   {
       echo ${i} ${probabilities[${i}]}
   }
   read -p"Number of probability: " p
   probability=${probabilities[${p}]}
fi

#
# Product to which to submit the bug
# Prompt if not set on command-line
#
if ((!${#product}))
then
   for ((i=0;i<${#products[*]};i++))
   {
       echo ${i} ${products[${i}]}
   }
   read -p"Number of product: " p
   product=${products[${p}]}
   component='*Unknown%20(Triage)-'${compSuffix[${p}]}
fi

bzServer='https://bugzilla.houston.hpecorp.net:1181/bugzilla'

#
# use default cclist if not set on command-line
# if it is set, check for multiple addresses
#
if ((!${#cclistIN[*]}))
then
    cclist='matthew.glover%40hpe.com'
else
    cclist=${cclistIN[0]}
    for ((i=1;i<${#cclistIN[*]};i++))
    {
        cclist=${cclist}"&cc="${cclistIN[${i}]}
    }
fi

bedrock='Red%20Zone'

bzLink="${bzServer}"'/enter_bug.cgi?assigned_to=&attachurl=&blocked=&bug_file_loc=http%3A%2F%2F&bug_severity='"${severity}"'&bug_status=NEW&cc='"${cclist}"'&cf_defecttype=Defect&cf_foundby=Build&cf_probability='"${probability}"'&cf_bedrock='"${bedrock}"'&comment=&component='"${component}"'&contenttypeentry=&contenttypemethod=autodetect&contenttypeselection=text%2Fplain&data=&deadline=&dependson=&description=&estimated_time=0.0&form_name=enter_bug&keywords=&maketemplate=Remember%20values%20as%20bookmarkable%20template&op_sys=Linux&priority=P2&product='"${product}"'&qa_contact=&rep_platform=All&short_desc='"${summary}"'&target_milestone=For%20Review&version='"${version}"

bugHtml="submit_${product}_${severity}Bug.html"

# create first embeded object
cat > ${bugHtml}<< eof
<html><body>
        <a name="top"/>
eof

# add submit
cat >> ${bugHtml} << eof
        <br>
        <a href="#top">Top</a><br>
        <a name="submit"/>
        <a href=${bzLink} target="_blank">${product} ${severity} bug submit</a>
eof

# close the html, not strictly required, but is well formed html
cat >> ${bugHtml} << eof
</body></html>
eof
