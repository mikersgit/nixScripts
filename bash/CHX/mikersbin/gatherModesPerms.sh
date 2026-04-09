#!/bin/bash

statFmt="%a %u:%g %n"

function setDirs() {
	dirs="autorun
	bin
	boot
	data
	dev
	etc
	firmware
	home
	lib
	lost+found
	media
	opt
	proc
	root
	run
	sbin
	srv
	sys
	systemrw
	tmp
	uEnv.txt
	update
	usr
	var"
}

#
# get long listing for top level directories
#
function doTopDirsOnly() {
   for d in ${dirs}
   do
     if [ -e $d ]
     then
        stat -c "${statFmt}" ${d}
     fi
   done
}

#
# NB: /proc, /sys, /run must be root:root, but we do not decend those dirs to avoid a flood of output
#
function doNonRootFind() {
  type=${1}
  uORg="-${2}"
  echo -e "\n\t========= ${type}: not root ${uORg} =======" >&2
  for d in ${dirs}
  do
     if [ -e $d ]
     then
       find ${d} -type ${type} \( ! -path proc\* ! -path sys\* ! -path run\* ! -path systemrw\* ! -path home\* \) ! -perm /7000 ! ${uORg} root -exec stat -c "${statFmt}" {} \; 2>/dev/null
     fi
  done
}

function doSpecialModeFind() {
  mode=${1}
  name=${2}
  type=${3}

  echo "=========== ${name} ${type}========" >&2
  for d in ${dirs}
  do
   if [ -e $d ]
   then
       find ${d} -type ${type} \( ! -path proc\* ! -path sys\* ! -path run\* ! -path systemrw\* ! -path home\* \) -perm /${mode}  -exec stat -c "${statFmt}" {} \; 2>/dev/null
   fi
  done
}


# exclude files and dirs with setuid, setgid, or sticky bits
#
function doRegModeFind() {
  echo "=========== Non special perms ========" >&2
  for d in ${dirs}
  do
   if [ -e $d ]
   then
     find ${d} \( ! -path proc\* ! -path sys\* ! -path run\* ! -path systemrw\* ! -path home\* \) ! -perm /7000 -exec stat -c "${statFmt}" {} \; 2>/dev/null
   fi
  done

}


function getNonRootPerms() {
# Do the top level dirs first, then the exceptions next
#
   echo "=========== get non-root users and groups ========" >&2

   for t in f d l
   do
     for ug in user group
     do
       doNonRootFind ${t} ${ug}
     done
   done
}

function getSpecialModes() {
   # setuid
   smodes=(4000 2000 1000)
   smdesc=(setuid setgid sticky)

   for i in 0 1 2
   do
      for t in f d
      do
          doSpecialModeFind ${smodes[${i}]} ${smdesc[${i}]} ${t}
      done
   done
     
}

function getRegularModes() {
   echo "=========== non set[ug]id, or sticky ========" >&2
   doRegModeFind 
}

if [ $# -lt 1 ]
then
   echo "USAGE: ${0} <img mount dir>"
   echo "   eg. ${0} /mnt/timg"
   exit 1
fi

here=${PWD}
cd ${1}
prfx="${here}/${2}"

setDirs
doTopDirsOnly >> ${prfx}TopDPerms.txt
getNonRootPerms >> ${prfx}NonRootPerms.txt
getSpecialModes >> ${prfx}SpecialPerms.txt
getRegularModes >> ${prfx}RegularPerms.txt

echo "======= waiting for finds =" >&2
wait
# takes about 4 minutes with 'finds' parallel in background. need to try serialized and determine
# if that makes a difference.
#  echo $b| awk '{print index($3,"/")}' # if this is zero, then top level dir
mount dir> [label]"
   echo "   eg. ${0} /mnt/timg Tbone2025005"
   exit 1
fi

TOMAP=${1}
LABEL=${2}
here=${PWD}
cd ${TOMAP}
prfx="${here}/${LABEL}"

setDirs
getLayout >> ${prfx}FileDirCount.txt
doCount >> ${prfx}FileDirCount.txt
doTopDirsOnly >> ${prfx}TopDPerms.txt
getNonRootPerms >> ${prfx}NonRootPerms.txt
getSpecialModes >> ${prfx}SpecialPerms.txt
getRegularModes >> ${prfx}RegularPerms.txt

echo "======= waiting for finds =" >&2
wait
# package up the files
cd $here
tar --xz -cvf ${LABEL}FileInfo.tar ${LABEL}*txt
ls -l ${LABEL}FileInfo.tar
# takes about 4 minutes with 'finds' parallel in background. need to try serialized and determine
# if that makes a difference.
#  echo $b| awk '{print index($3,"/")}' # if this is zero, then top level dir
