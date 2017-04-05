#!/bin/bash
#
# script to generate Bugzilla multi-select URL for batch processing from
# an input file that contains one bug number per line.
#######

# Input file 'buglist'
BUGFILE=buglist

# Number of bugs to process in a chunk
CHUNK=25

ResText="Moving Resolved or Verified bugs to Closed that are at least 6 months old and resolution is Abandoned, CantReproduce, Duplicate, Invalid or WontFix, without any further verification."

#########
# URL parts from which to build the query for batch changes (these do not change)
#BEG='https://bugzilla.houston.hpecorp.net:1181/bugzilla/buglist.cgi?bug_id='
#SEP='%2C'
#ENDstr='&bug_id_type=anyexact&order=bug_id&query_format=advanced&tweak=1'
##########
########
# URL codes
# SPACE = %20
# SingleQoute = %27
# DoubleQuote = %22
# Period = %2E
# comma = %2C
########
# URL for EXECUTING a batch change
BEG='https://bugzilla.houston.hpecorp.net:1181/bugzilla/process_bug.cgi?'
SEP='=on&'
ENDstr='&bug_status=CLOSED&comment=Moving%20Resolved%20or%20Verified%20bugs%20to%20Closed%20that%20are%20at%20least%206%20months%20old%20and%20resolution%20is%20Abandoned%2C%20CantReproduce%2C%20Duplicate%2C%20Invalid%20or%20WontFix%2C%20without%20any%20further%20verification%2E&no_mass_mail=no_mass_mail&token=Gle3zLkadX'
PREF='id_'
#########

#
# function to create a cut/paste URL from accumulated bugs
#
function CreateURL() {
    # append most recently read bug number
    B=${B}${SEP}${b}"=on"
            #echo "wrote: ${b}" >> out
    echo "${j}/${t} === ${i} bugs in chunk === Last bug in this list: ${b}"
    # echo -e "\t>>>>> Cut/Paste https:// line into Browser <<<<<\n"
    # echo ${BEG}${B}${ENDstr}
    URL="${BEG}${B}${ENDstr}"

    /cygdrive/c/Program\ Files\ \(x86\)/Mozilla\ Firefox/firefox.exe ${URL}
    # comment for the commit
    # echo -e "\n${ResText}"

    B=''
    b=''
    # pause to cut/paste into browser
    read -p "PAUSE  " ans
    # clear screen
    # clear
    # increment chunk count
    ((j+=1))
} # end CreateURL function

# number of lines in input file
k=$(wc -l ${BUGFILE}|awk '{print $1}')
# position in CHUNK
i=0
# Number of CHUNKs processed
j=1
# number of CHUNKs
((t=(k/CHUNK)))

# Loop through bug file
for b in $(< ${BUGFILE})
{
	b=${PREF}${b}
    #echo "read: ${b}" >> out
    ((i+=1))
    if ((i==CHUNK))
    then
        CreateURL ${B}
        i=0
    else
        if ((i==1))
        then
            B=${b}
            #echo "wrote: ${b}" >> out
            b=''
        else
            B=${B}${SEP}${b}
            #echo "wrote: ${b}" >> out
	    lastb=${b} #to capture last element when it is <25
            b=''
        fi
    fi
    if ((${#b} > 0 ))
    then
        echo "dropped a bug: ${b}"
    fi
} # end of for b loop
b=${lastb}
CreateURL ${B}

# https://bugzilla.houston.hpecorp.net:1181/bugzilla/process_bug.cgi?
# id_48946=on&id_48969=on
# &bug_status=CLOSED
# &comment=Moving%20%27Resolved%27%20bugs%20to%20%27Closed%27%20that%20are%20over%202%20years%20old%2C%20without%20further%20verification%2E"
# &no_mass_mail=no_mass_mail&token=Gle3zLkadX

# https://bugzilla.houston.hpecorp.net:1181/bugzilla/process_bug.cgi?id_48946=on&id_48969=on&bug_status=CLOSED&comment=Moving%20%27Resolved%27%20bugs%20to%20%27Closed%27%20that%20are%20over%202%20years%20old%2Cwithout%20further%20verification%2E&no_mass_mail="no_mass_mail"&token=Gle3zLkadX
