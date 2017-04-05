#!/bin/bash

# script to build only a subtree with coverage, and then build
# complete ISO for install. the default subtree is 'tools'.
#

if [[ $1 =~ -[?|h] ]]
then
	echo "usage: ${0##*/} pathToFmt_0 [subDir to instrument]"
	echo "e.g. ${0##*/} /root/workspace/stt/fmt_0 tools"
	exit 2
fi

if (( ! ${#} ))
then
	echo "supply path of fmt_0 to build (inclusive)"
	exit 2
fi

if (( ${2} ))
then
	subDir=${2}
else
	subDir='tools'
fi

# get to top of src tree
fmt0Dir=${@}
cd ${fmt0Dir}

echo "**********************************************************"
echo "Building in: ${fmt0Dir}, instrumenting subtree: ${subDir}."
echo "**********************************************************"
sleep 4

# make sure coverage is turned off
cov01 --off
export COVFILE=/var/local/ibrcov.cov

#remove previous coverage master file
rm -f ${COVFILE}

# make clean, and remove old cov files
make clean || exit 2
find . -name test.cov | xargs rm -f 

# make twice in case the out of memory error pops up
make ; make 

# get to the tools dir, clean it out, turn coverage on make, then turn
# coverage off
cd ${subDir}  
make clean 
cov01 --on 
make | tee ~/build.out
cd ${fmt0Dir}
make pkgfull 2>&1 | tee -a ~/build.out
cov01 --off
