#!/bin/bash

FS='fs1_42'
SNAPTR='/fs1_42/d1/d2'
SHARE='fs1_d1_d2'
fd1='fold1'
fd2='fold2'
f1='f1.txt'
f2='f2.txt'
SNAPB='snapb'
SHIP='10.30.236.149'
SHAdmin='dev\Administrator'
SHPass='hpinvent#1'
DRIVEltr="W"

SNAPcnt=0
SEQcnt=0
IBRSNAP='/usr/local/ibrix/bin/ibrix_snap'
IBRSNAPREC='/usr/local/ibrix/bin/ibrix_snapreclamation'
LWSHARE='/opt/likewise/bin/lw-share'

#
# print banner with stars
#
function msg(){
	local cnt=${#1};local sline='';local c
	for ((c=1;c<=(cnt+4);c++)); { sline=${sline}'*'; }
	echo -e "\n\t${sline}\n\t* ${@}\n\t${sline}\n"
} # end msg()

# Create ibrix snapshot
function doSnap() {
    msg "Create snapshot ${SNAPcnt} of ${SNAPTR}"
    ${IBRSNAP} -c -f ${FS} -P ${SNAPTR} -n ${SNAPB}${SNAPcnt}
    ((SNAPcnt+=1))
}

# List snapshots
function listSnap() {
    ${IBRSNAP} -l -s -f ${FS}
}

# Pause with sequence number
function pause() {
    read -p"${SEQcnt}: ${@}" ans
    (( SEQcnt+=1 ))
}

msg "List share info for ${SHARE}"
${LWSHARE} get-info ${SHARE}

msg "Create snap tree ${SNAPTR}"
${IBRSNAP} -m -f ${FS} -P ${SNAPTR}
find ${SNAPTR}

msg "Map share on Windows"
echo -e "\nnet use "${DRIVEltr}': \\\\'${SHIP}'\\'${SHARE} ${SHPass}' /user:'${SHAdmin}
pause "Enter when share is ready" 

msg "Create directories and files on Windows"
echo -e "start ${DRIVEltr}:"
echo -e 'In Explorer create '${DRIVEltr}':\\'${fd1}','"\n"'a new file '${DRIVEltr}':\\'${f1}','"\n"'a new file '${DRIVEltr}':\\'${fd1}'\\'${f2}','"\n"' and subfolder '${DRIVEltr}':\\'${fd1}'\\'${fd2}''
pause "Enter when dirs and files are ready" 

doSnap

msg "Modify files on Windows"
echo -e 'In Explorer add V1 to files '${DRIVEltr}':\\'${f1}','"\n"'and file '${DRIVEltr}':\\'${fd1}'\\'${f2}''
pause "Enter when files are ready" 

msg "Browse previous versions on Windows"
echo -e 'In Explorer should see V0 of files '${DRIVEltr}':\\'${f1}','"\n"'and file '${DRIVEltr}':\\'${fd1}'\\'${f2}''
pause "Enter when previous versions of files have been browsed" 

msg "Restore previous version on Windows"
echo -e 'In Explorer restore V0 of files '${DRIVEltr}':\\'${f1}','"\n"'and file '${DRIVEltr}':\\'${fd1}'\\'${f2}''
pause "Enter when previous version of files have been restored" 

msg "Modify files on Windows"
echo -e 'In Explorer add V2 to files '${DRIVEltr}':\\'${f1}','"\n"'and file '${DRIVEltr}':\\'${fd1}'\\'${f2}''
pause "Enter when files are ready" 

doSnap

msg "List snapshots"
listSnap

msg "Modify files on Windows"
echo -e 'In Explorer add V3 to files '${DRIVEltr}':\\'${f1}','"\n"'and file '${DRIVEltr}':\\'${fd1}'\\'${f2}''
pause "Enter when files are ready" 

msg "Browse previous versions on Windows"
echo -e 'In Explorer should see V0 of files '${DRIVEltr}':\\'${f1}','"\n"'and file '${DRIVEltr}':\\'${fd1}'\\'${f2}''
pause "Enter when previous versions of files have been browsed" 

msg 'Delete  '${DRIVEltr}':\\'${fd1}'\\'${f2}' and subfolder '${DRIVEltr}':\\'${fd1}'\\'${fd2}' on Windows'
echo -e 'start /D '${DRIVEltr}': del /F /S /Q '${DRIVEltr}':\\'${fd1}'\\'${f2}'' 
echo -e 'start /D '${DRIVEltr}': del /F /S /Q '${DRIVEltr}':\\'${f1}'' 
echo -e 'start /D '${DRIVEltr}': rmdir /S /Q '${DRIVEltr}':\\'${fd1}'\\'${fd2}''
echo -e 'start /D '${DRIVEltr}': rmdir /S /Q '${DRIVEltr}':\\'${fd1}''
pause "Enter when file and dir have been removed" 

msg "unMap share on Windows"
echo -e "\nnet use "${DRIVEltr}": /DELETE"
echo -e "net use "'\\\\'"${SHIP} /DELETE"
pause "Enter when unMapped" 

msg "Remove snapshots"
for s in $(listSnap | tail --lines=+3 | awk '{print $2}')
{
    ${IBRSNAP} -d -f ${FS} -P ${SNAPTR}  -n ${s}
}

# msg "Run snapreclamation"
# ${IBRSNAPREC} -r -f ${FS}
# sleep 10

#msg "Remove snaptree"
#${IBRSNAP} -m -U -f ${FS} -P ${SNAPTR}
