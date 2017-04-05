#!/bin/bash

# Script to test the replication of acls and xattrs on a
# file that is already replicated. This tests that the meta-data
# events are properly replicated when no file data changes.
#
# ASSUMPTIONS: 1)  dogfood mount home_dirs/mwroberts/bin is mounted at /root/bin
#                  on remote cluster so that the command fileInfo.sh is available
#              2)  remote cluster is accessable via ssh
#              3)  continuous CRR task is already running to the remote cluster
##################

#
# initialize environment for tests
#
function initE() {
        ibrBin='/usr/local/ibrix/bin'
        srcFS='/fs1_40'
        targFS='/fs1_41'
        targIP='10.30.244.48'
        local dest="${srcFS}/${srcFL}"
        msg "create test file ${dest}"
        rm -f ${dest}
        sleep 5 # allow delete to propagate
        #echo hi > ${srcFS}/${srcFL} 
        dd if=/dev/urandom of=${dest} bs=4k count=100
} # end initE()

#
# output cluster and CRR summary info
#
function summary() {
        initE
        msg "Performing ${tests} test"
        msg "X9K info"
        ${ibrBin}/ibrix_version -l
        msg "CRR task info"
        ${ibrBin}/ibrix_crr -l
} # end summary()

#
# print banner with stars
#
function msg() {
	local cnt=${#1}
	local sline=''
	# create line of stars 4 longer than length of first argument to msg
	for ((c=1;c<=(cnt+4);c++)); { sline=${sline}'*'; }
	echo -e "\n\t${sline}\n\t* ${@}\n\t${sline}\n"
} # end msg()

#
# function version of fileInfo.sh script
# displays stat, cksum, acl, and xattr info for
# file
#
function getInfo() {
        # print "S"ize "A"time "M"time "C"time
        echo '*** stat and cksum info ***'
        stat --printf="S %s\nA %x\nM %y\nC %z\n" ${srcFL}
        cksum ${srcFL}
        echo -e '\n*** ACL info ***'
        getfacl ${srcFL}
        echo -e '*** XATTR info ***'
        getfattr -d -m ".*" ${srcFL}
} # end getInfo()

#################
## ACLS
#################
function SetSrcAcls() {
        msg "setting root group execute acl"
        set -x
        setfacl -m g:root:x ${srcFL} 
        set +x
} # end SetSrcAcls()

#################
## XATTRS
## set some xattrs on a file in different name spaces
#################
function SetSrcXattrs() {
        msg "Setting: security.lwiod, user.lwiod, user.lwiod_sd_v1,\n\t* user.lwio, user.lwio_sd_v1, wsystem.lwiod"
        # setfattr --name=system.lwiod -v "system info" ${srcFL}
        for n in security.lwiod user.lwiod user.lwiod_sd_v1 user.lwio user.lwio_sd_v1 wsystem.lwiod
        {
                set -x
                setfattr --name=${n} -v "${n} info" ${srcFL}
                set +x
        } 
} # end SetSrcXattrs()

#
# show state of local and remote file
#
function checkInfo() {

        msg "LOCAL info ${1} ${testType}"
        getInfo ${srcFL}
        sleep 10

        msg "REMOTE info ${1} ${testType}"
        ssh ${targIP} "/root/bin/fileInfo.sh ${targFS} ${srcFL}"

} # end checkInfo()

#
# run requested test type
# show file info before and after each test
# for both the local and replicated file
#
function runTests() {
        tests="${1}"
        shift 1
        summary ${srcFL}
        cd ${srcFS}
        for testType in ${@}
        {
                checkInfo Before ${testType}
                case ${testType} in
                        ACL) SetSrcAcls ${srcFL} ;;
                        XATTR) SetSrcXattrs ${srcFL} ;;
                esac
                checkInfo After ${testType}
        }
} # end runTests()

##
## MAIN
##
srcFL=${2}
case ${1} in
        a)   runTests 'ACL only' ACL ;;
        x)   runTests 'XATTR only' XATTR ;;
        A)   runTests 'ACL and XATTR combined' ACL XATTR ;;
        *) echo "usage: ${0##*/} [a|x|A] fileName"
           echo "       a== acl tests"
           echo "       x== xattr tests"
           echo "       A== both acl and xattr tests"
esac
