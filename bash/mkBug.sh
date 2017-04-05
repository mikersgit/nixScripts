#!/bin/bash

# create a bug directory, and a bug link to bugzilla
# if one bug, then full height frame, if more than one bug
# then height of 220
####
# muliple bugs quicksearch
# http://bugzilla.atlanta.hp.com/bugzilla/buglist.cgi?quicksearch=19924%2C19925
bzServer='https://bugzilla.houston.hpecorp.net:1181/bugzilla'
bzQsearch="${bzServer}"'/buglist.cgi?quicksearch='
bzShow="${bzServer}"'/show_bug.cgi?id='
bn=$1
w=1400
h=1000
bugdir='/root/bin/bugs'

if (( ${#} < 1 ))
then
        echo "Need bug number(s) on command line, master first"
        exit 1
else
        (( ${#} > 1 )) && h=220
fi

pth="${bugdir}/bug_${bn}"
mkdir -p ${pth}
bugHtml="${pth}/bug_${bn}.html" 
bgList=""
for i in ${@}
{
        if (( ${#bgList} )) ;then bgList="${bgList}%2c${i}"
        else bgList="${i}" ;fi
}

# create first embeded object
cat > ${bugHtml}<< eof
<html><body>
        <a name="top"/>
        <a href="#search">Search</a><br>
        <object width="${w}" height="${h}" data=${bzShow}${bn}></object>
        <a href="${bzShow}${bn}" target="_blank">${bn}</a>
eof

# shift past first argument
shift 1

# create objects for any additional bugs separated by a line
for b in ${@}
{
        cat >> ${bugHtml} << eof
        <hr>
        <object width="${w}" height="${h}" data=${bzShow}${b}></object>
        <a href="${bzShow}${b}" target="_blank">${b}</a>
eof
}

# add search query
cat >> ${bugHtml} << eof
        <br>
        <a href="#top">Top</a><br>
        <a name="search"/>
        <a href=${bzQsearch}${bgList} target="_blank">Bug search</a>
eof

# close the html, not strictly required, but is well formed html
cat >> ${bugHtml} << eof
</body></html>
eof
