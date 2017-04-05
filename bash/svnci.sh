#!/bin/bash

# create correctly formated ci log message file and commit
# assumes that branches are of the form /branches/private/first.last/bug9999

cifile=""
cimsg=""
cimsgFile=$(mktemp -t cifile.XXXXXX)

svnURL=$(svn info |grep -e ^URL | awk '{print $NF}')
	
# try to determine bug from branch path
bug=$(echo ${svnURL##*bug} | cut -d '/' -f 1)

function usage(){
	echo "usage: ${1} [-b BugNumber] [-m 'quoted message'] [-f filesToCommit]"
        rm -f ${cimsgFile}
	exit 2
} # usage()

while getopts :b:m:f: OPT; do
    case $OPT in
	b|+b)
	bug="$OPTARG"
	;;m|+m)
	cimsg="$OPTARG"
	;;f|+f)
	cifile="$OPTARG"
	;;*)
                usage ${0##*/}
    esac
done

# if no message provided on command line then prompt for one
# else echo the message into the temp file
if (( ${#cimsg} < 1 ))
then
        echo "Type comments then 'ctrl-D' when done."
        cat - > ${cimsgFile} 
else
        echo -e "${cimsg}" > ${cimsgFile}
fi

# if bug number couldn't be determined, or was not provided, prompt for it
if ! echo ${bug} | grep ^[[:digit:]] 2>&1 > /dev/null
then
        read -p"Need bug number: " bug
fi

#   echo https://svn01.atlanta.hp.com/local/swd-usd-eng/branches/private/michael.roberts/bug15981/fmt_0/tools |
#        sed 's!'${repr}'!!' | sed 's!/fmt_0/tools!!'
#   f=/branches/private/michael.roberts/bug15981/fmt_0/tools
#   echo ${f%fmt_0*}
#   f=https://svn01.atlanta.hp.com/local/swd-usd-eng/branches/private/michael.roberts/bug15981/fmt_0/tools
#   echo ${f%fmt_0*}
#   g=${f%fmt_0*}
#   echo ${g##*usd-eng}
# repr='https://svn01.atlanta.hp.com/local/swd-usd-eng'
#  echo ${g##*${repr##*/}}

# get the part of the URL that is not the server path, but does include the subdirectory of the working copy
branchPath=${svnURL##*branches/}

# get the path to just the branch, not including the working copy subdirectory
branch=${branchPath%fmt_0*}

if echo ${branch} | grep trunk 2>&1 >/dev/null
then
        branch="trunk"
fi

CIFILE="ciBug${bug}.txt"

# do not overwrite prevous ci file with same bug number
if [[ -f ${CIFILE} ]]
then
        CIFILE="ciBug${bug}_$$.txt"
fi

#
# build the ci file
# begin with bug number and branch
#
cat > ${CIFILE} <<EOF
Bug: ${bug}
Branch: ${branch}

EOF

# add checkin message
cat ${cimsgFile} >> ${CIFILE}

# append files modified
cat >> ${CIFILE} << EOF

Files modified
$(svn st | grep -v ^?)
EOF

#
# completed building ci file
#

# remove temp file
rm -f ${cimsgFile}

echo -e "\nTo commit changes with this information run the command:\n"
echo "svn ci -F ${CIFILE} ${cifile}"
