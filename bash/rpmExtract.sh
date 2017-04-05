#!/bin/bash

OPER=$1
RPM=$2
FILE=$3

case ${OPER} in
        l)
                # list
                rpm2cpio ${RPM} |
                cpio -it
                ;;
        x)
                # extract
                rpm2cpio ${RPM} |
                cpio -i -duv ${FILE}
                ;;
        *)
                echo "usage: ${0##*/} [l|x] RPM FILE"
                exit 1
                ;;
esac
