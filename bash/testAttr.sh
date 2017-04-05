#!/bin/bash

#
# script to test the ability of various linux commands to retain xatters.
# 
SRCd='src'
TGTd='tgt'
SRCf="${SRCd}/InfoAttr"
TGTf="${TGTd}/InfoAttrTgt"
IBRd='/fs3_41/attrTestIBRfs'
EXT3='/var/tmp/attrTestIBRfs'

LINE='####################################'

for d in ${SRCd} ${TGTd} ${IBRd}
{
    mkdir -p ${d}
}

#
# set some xattrs on a file in different name spaces
#
function SetSrcXattrs() {

        rm -rf ${SRCd}/* ${TGTd}/*
        touch ${SRCf}
        echo "Setting: security.lwiod, system.lwiod, user.lwiod, wsystem.lwiod"
        setfattr --name=security.lwiod -v "security info" ${SRCf}
        setfattr --name=system.lwiod -v "system info" ${SRCf}
        setfattr --name=user.lwiod -v "user info" ${SRCf}
        setfattr --name=wsystem.lwiod -v "wsystem info" ${SRCf}
        echo -e "\n\t${LINE}\n\t# initial attrs #\n\t${LINE}"
        getfattr -d -m ".*" ${SRCf}
}

function msg() {
        echo -e "\n\t${LINE}\n\t# ${@} #\n\t${LINE}"
}

function tlmsg() {
    msg "Test Local ${@} \n\t${LINE}"
}

function vlmsg() {
    msg "Verify ${@} target xattrs"
}


function trmsg() {
    msg "Test ${@} from ext3 to Ibrix\n\t${LINE}"
}

function vrmsg() {
    msg "Verify ${@} ext3 to Ibrix target xattrs"
}

############ CP ####################
####################################

tlmsg "cp"

SetSrcXattrs

\cp ${SRCf} ${TGTf}

vlmsg "cp"

getfattr -d -m ".*" ${TGTf}

############ MV LOCAL ####################
####################################

tlmsg "mv"

SetSrcXattrs

\mv ${SRCf} ${TGTf}

vlmsg "mv"

getfattr -d -m ".*" ${TGTf}

############ MV IBRIX ##############
####################################

rm -rf ${IBRd}/*

trmsg "mv"

SetSrcXattrs

\mv ${SRCf} ${IBRd}

vrmsg "mv"

getfattr -d -m ".*"  ${IBRd}/*

############ PAX LOCAL #############
####################################

tlmsg "pax"

SetSrcXattrs

pax -rw -pe ${SRCd} ${TGTd}

vlmsg "pax"

find ${TGTd} |xargs getfattr -d -m ".*"

############ PAX IBRIX #############
####################################

rm -rf ${IBRd}/*

trmsg "pax"

SetSrcXattrs

pax -rw -pe ${SRCd} ${IBRd}

vrmsg "pax"

find ${IBRd}|xargs getfattr -d -m ".*"


############ cpio LOCAL #############
####################################

tlmsg "cpio"

SetSrcXattrs

find ${SRCd} -print0 | cpio --null -pd ${TGTd}

vlmsg "cpio"

find ${TGTd} |xargs getfattr -d -m ".*"

############ cpio IBRIX #############
####################################

rm -rf ${IBRd}/*

trmsg "cpio"

SetSrcXattrs

find ${SRCd} -print0 | cpio --null -pd ${IBRd}

vrmsg "cpio"

find ${IBRd}|xargs getfattr -d -m ".*"

############ rsync local ###########
####################################

tlmsg "rsync"

SetSrcXattrs

rsync -Xa  ${SRCd} ${TGTd}

vlmsg "rsync"

find ${TGTd} |xargs getfattr -d -m ".*"

############ rsync IBRIX ###########
####################################

rm -rf ${IBRd}/*

trmsg "rsync"

SetSrcXattrs

rsync -Xa ${SRCd} ${IBRd}

vrmsg "rsync"

find ${IBRd}|xargs getfattr -d -m ".*"

############ tar local ###########
####################################

tlmsg "tar"

SetSrcXattrs

opwd=${PWD}
tar --xattrs -cf ${TGTd}/IA.tar ${SRCd}
cd ${TGTd}
tar --xattrs -xf IA.tar
cd ${opwd}

vlmsg "tar"

find ${TGTd} |xargs getfattr -d -m ".*"

############ tar IBRIX ###########
####################################

rm -rf ${IBRd}/*

trmsg "tar"

SetSrcXattrs

opwd=${PWD}
tar --xattrs -cf ${IBRd}/IA.tar ${SRCd}
cd ${IBRd}
tar --xattrs -xf IA.tar
cd ${opwd}

vrmsg "tar"

find ${IBRd}|xargs getfattr -d -m ".*"
