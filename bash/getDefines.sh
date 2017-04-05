#!/bin/bash
TMPFL=$(mktemp)
SRCBASE=${PWD}
DOXDEF=${SRCBASE}/hpdocs/dox/DoxyfileDefs
HPSMBDEFS=${SRCBASE}'/lwbase/include/lw/hp_defs.h'
DEFCMNT='# These defines are derived from processing the *.c and *.h
# in lwio, and by processing the lwbase/include/lw/hp_defs.h file.
#'

echo ${DEFCMNT} > ${DOXDEF}

# Look for defines in source files, exclude any "! defined" 
# , exclude 'HP' and 'SED' (Steve Douglas specific), exclude any patterns
# with non-alnum characters.
cd ${SRCBASE}/lwio
find . -type f -name \*.[ch]             |
	xargs grep '\#if defined(HP)'    |
	awk '{print $NF}'                |
	sed -e 's/defined(//' -e 's/)//' |
	grep -v !                        |
	awk '{if ( $1 !~ /[\(\)]/ && \
                   $1 !~ /^HP$/ && \
                   $1 !~ /^SED$/ && \
                   $1 ~ /[[:alnum:]]/) 
                     printf("%s\n",$1)
             }' > ${TMPFL}

cd ${SRCBASE}

# extract the defines from hp_defs.h
# and combine with previous list
grep ^\#define ${HPSMBDEFS} |
    awk '$2 !~ /^_/ {printf("%s\n",$2)}' >> ${TMPFL}

# Sort and unique the symbols, output the PREDEFINED doxygen tag
# into the DoxyfileDefs file.
sort -u ${TMPFL} |
   awk 'BEGIN {printf("PREDEFINED = HP ")}
        {
            printf("\\\n\t\t%s ",$1)
        }
        END {printf("\n")}' >> ${DOXDEF}

rm -f ${TMPFL}
exit 0
