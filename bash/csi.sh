#!/bin/bash

# run cscope with custom file list, regenerate list if older than 15 minutes,
# allow for "force" and "no update" options.
# do not rebuild cross reference if file list not regenerated
#

# cscope files list
CSF='cscope.files'
CSO='cscope.out'
n_opt=0
csopt=""
CTAGSopts=''
prog=${0##*/}
CS_MODE=0 # default read only
SCOPE='/usr/bin/cscope'
CTAGS=$(which ctags)

function usage() {
	echo "${prog} [-n|-f] [-w] [-v|-e]"
	echo -e "\t-n do not update any cscope data files if they exist"
	echo -e "\t-f update all cscope data files even if they are recent"
	echo -e "\t-w run editor in write mode"
	echo -e "\t-v run editor (vim) in same window as cscope"
	echo -e "\t-e cscope editor is emacs (Def: == gvim)"
	exit 1
}

CSCOPE_WRITABLE=0

# emacs, vim, gvim
E=0; V=0 ; G=1

while getopts :nfwve OPT; do
    case $OPT in
	n) # '-n' do not update anything if cscope file exists
	    if [[ -f ${CSF} ]]
	    then
		[[ -f ${CSO} ]] && n_opt=1
	    fi
	;;f) # '-f' forces rebuild of cscope file list regardless of time
	    rm -f ${CSF} ${CSO}
	;;w) # write-able mode
	    CSCOPE_WRITABLE=1
	;;v) # in cscope window editting
                E=0; V=1 ; G=0
	;;e) # edit with emacs in separate window
                E=1; V=0 ; G=0
                CTAGSopts='-e'
	;;*)	usage
    esac
done
shift $[ OPTIND - 1 ]

# command to invoke either gvim or emacs when this command is set as
# default to gvim

((G)) &&  ED=$(which gvimScope.sh)
((E)) &&  ED=$(which emacsScope.sh)

if ((V))
then
        ED=$(which vim)
        (( ! CSCOPE_WRITABLE )) &&  ED=${ED%/*}/view
fi

cfds=0
[[ -f ${CSO} ]] && csopt='-d' # do not update cscope.out

# get current time 'ds' and mod time from cscope files list 'cfds'
# cfds remains zero if no cscope file list exists so it will get created
#
ds=$(date '+%Y%m%d%H%M%S')

# get time stamps for cscope files
[[ -f ${CSF} ]] &&
      cfds=$(ls -l --time-style '+%Y%m%d%H%M%S' ${CSF}| awk '{print $6}')
[[ -f ${CSO} ]] &&
      cods=$(ls -l --time-style '+%Y%m%d%H%M%S' ${CSO}| awk '{print $6}')

(( n_opt )) && cfds=${ds}

# update the cross reference if older than 30 minutes
# and the '-n' flag not used
#
(( (ds - cods) > 3600 && ! n_opt )) && csopt=""

##
# exclude test directories, svn files, generated files in "target"
# directories, likewise 'pvfs' directories, and cscope files
# include C, C++, Java, Python, JavaScript, Shell, Perl file types
#
# if cscope files list is more than 15 minutes old, create a new one
if (( (ds - cfds) > 3600 ))
then
        \find . -type f \( ! -path \*tests/\* -a ! -path \*.svn\* \
                -a ! -path \*test/\* -a ! -path \*/target/\* \
                -a ! -path \*debug/\* -a ! -path \*/pvfs/\* \
                -a ! -path \*/ibfs_old/\* \) \
                \( -name \*.[ch] -o -name \*.in \
                -o -name \*.cpp -o -name \*.java -o -name \*.py \
                -o -name \*.js  -o -name \*.sh -o -name \*.pl \) \
               ! -name ${CSF} > ${CSF}
               csopt=""
		# if the ctags command exists then generate tags file
               [[ -x ${CTAGS} ]] && ${CTAGS} ${CTAGSopts} -f tags -L ${CSF} &
               [[ -x ${CTAGS} ]] && ${CTAGS} -e -f eTags -L ${CSF} &
fi

export CSCOPE_WRITABLE=${CSCOPE_WRITABLE}
export CSCOPE_EDITOR=${ED}
${SCOPE} -i ${CSF} ${csopt}
