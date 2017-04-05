#!/bin/bash

# find that skips files I don't care about

# ignore the extentions: tar tgz rpm o iso jar gz zip a class 0 fm doc

find . -type f ! -path \*.svn\* \
        -a \( ! -name \*.tar -a ! -name \*.tgz -a ! -name \*.rpm -a ! -name \*.o -a \
        ! -name \*.iso -a ! -name \*.jar -a ! -name \.gz -a ! -name \*.zip -a \
        ! -name \*.a -a ! -name \*.class -a ! -name \*.0 -a ! -name \*.fm -a ! -name \*.doc \)

