#!/bin/bash

# find to xargs, ignoring archives (tar, tgz, rpm, zip), binaries (.o,.a,.class,.0), and images (.iso)
#      , Binary document formats (framemaker [fm], MS [doc]) 

PATTERN=' '

for p in ${@}
{
        PATTERN="${PATTERN} -e ${p}"
}

# ignore the extentions: tar tgz rpm o iso jar gz zip a class 0 fm doc

find . -type f ! -path \*.svn\* \
        -a \( ! -name \*.tar -a ! -name \*.tgz -a ! -name \*.rpm -a ! -name \*.o -a \
        ! -name \*.iso -a ! -name \*.jar -a ! -name \.gz -a ! -name \*.zip -a \
        ! -name \*.a -a ! -name \*.class -a ! -name \*.0 -a ! -name \*.fm -a ! -name \*.doc \) |
        xargs grep -i ${PATTERN} 2>/dev/null

