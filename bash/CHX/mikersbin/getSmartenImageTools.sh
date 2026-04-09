#!/bin/bash
exoduscenter=50.116.29.158
URLS=(https://${exoduscenter}/files/misc/dpkg/SmartenImageDeps.tar)
for f in ${URLS[@]}
{
        wget $f
}
if [ -e SmartenImageDeps.tar ]; then
        tar -xvf SmartenImageDeps.tar
        ./installSmartenImage.sh
else
        echo "ERROR: File SmartenImageDeps.tar not retrieved"
        exit 1
fi
