#!/bin/bash
inputFile=${1}
targDir=${2}

# these numeric user IDs are used by doChroot and specialDirs
rt=0
oper=37
adm=4

if [ $# -lt 2 ]
then
   echo "USAGE: $0 modePermsFile /mnt/img"
   exit 1
fi

if [ ! -e "${inputFile}" ]
then
    echo "could not find ${inputFile}"
    exit 1
fi

if [ ! -e "${targDir}" ]
then
    echo "specify target directory"
    exit 1
fi


echo "Takes approximately 15 minutes"

#
# on BBB running Smarten, lower priority of product while running this command
# and then put it back. Could also just stope with 'monit stop all'
#
function changePrio() {
    procs="dotnet hmi.qt5 ExodusCmain.exe SchneiderKeep"
    prio=$1
    for p in ${procs}
    {
	PID=$(pgrep ${p})
	if [ ${#PID} -gt 3 ]; then	
		renice --priority ${1} --pid ${PID}
	fi
    }

} # end changePrio()

#########
function doModesPerms() {
    #########
    # NB: chmod must come AFTER chown, else any special modes get overwritten
    #########
    exec 7<${inputFile}
    while read -u 7 mode userGroup fpath
    do
	fp="${targDir}/${fpath}"
       if [ -e "${fp}" ]
       then
          if echo "${fpath}"|grep -q '/'
          then
               #echo "BEFORE: "$(stat -c "%a %u:%g %n" ${fp})
              chown ${userGroup} "${fp}"
              chmod ${mode} "${fp}"
               #cho "AFTER: "$(stat -c "%a %u:%g %n" ${fp})
          else
              # recurse on top level dirs
              echo "===================" >&2
              echo "Top Level: ${fp}" >&2
              echo "===================" >&2
              chown -R ${userGroup} "${fp}"
              chmod -R ${mode} "${fp}"
          fi
       else
          #echo -e "\t*"${fp}" does not exist" >&2
	/bin/true
       fi
    done
    exec 7<&-
} # end doModesPerms()

#
# chroot to image root to set '/' owner:group and mode
#
# 'EOF' must be prefaced by 'tab' to end the here doc
function doChroot() {
    echo "chroot to set '/' mode/perm" >&2
    cat <<-EOF | chroot ${targDir}
    /bin/chown ${rt}:${adm} /
    /bin/chmod 755 /
	EOF

} # end doChroot()

# /home should be 777 root:root
# /mnt should be 775 root:operator
#
function specialDirs() {
    echo -e "\t============\n\tHome and Mnt\n\t==========="

    chown -h ${rt}:${rt} ${targDir}/home
    chown -h ${rt}:${oper} ${targDir}/mnt
    #doSync "home:mnt"

    chmod 777 ${targDir}/home
    chmod 755 ${targDir}/mnt
} # end specialDirs()

# lower process priority of smarten product
changePrio 10

specialDirs
doModesPerms
doChroot

# restore smarten process priority
changePrio 0
