#!/bin/bash
#
# ChampionX (c) 2024
# Prepare the system for Visual Studio remote debugging.
# You can:
# -i setup a system fresh for debugging
# -u update system to take another build
# -F put the system back to release state
# -c remove the debug directories to which VS downloads so that next
#    build & deploy downloads new debug scripts from MicroSoft
#####################3

function Init() {
	ExHome=/home/exodus
	ExHomeDbg=${ExHome}/.vs-debugger
	RootDbg=/root/.vs-debugger
	HOSTS='/etc/hosts'
	AKA='23.54.202.151	aka.ms'
	VSDBG='72.21.81.200	vsdebugger.azureedge.net'
	VSDBGblob='20.209.142.129	vsdebugger.blob.core.windows.net'
	DOTNETblob='52.239.161.42	dotnetcli.blob.core.windows.net'
} # end Init()

function UpdateHosts() {

	if grep -q "${AKA}" ${HOSTS}
	then
		echo "${HOSTS} up-to-date"
	else
		echo "Adding debug hosts to ${HOSTS}"
		sudo -s <<-eof
		echo "## hosts for Visual Studio 2022 remote debugging" >> ${HOSTS}
		echo "${AKA}" >> ${HOSTS}
		echo "${VSDBG}" >> ${HOSTS}
		echo "${VSDBGblob}" >> ${HOSTS}
		echo "${DOTNETblob}" >> ${HOSTS}
		eof
	fi

} # end UpdateHosts()

function CleanDbgDirs(){
	for d in ${ExHomeDbg} ${RootDbg}
	{
		if [ -e ${d} ]
		then
			echo "Removing ${d}"
			sudo rm -rf ${d}
		else
			echo "${d} not found"
		fi
	}
} # CleanDbgDirs()

function CopyEngSave() {
	dbgDir=${ExHome}/GenesisMcp
	saveDir=${ExHome}/Engine.sav
	cd ${saveDir}
	echo "in $PWD"
	ls | while read FILE
	do
		if [[ -e ${dbgDir}/${FILE} ]]
		then
			#echo "${FILE} exists in both"
			:
		else
			echo "${FILE} only in Engine"
			sudo cp -R ${FILE} ${dbgDir}/${FILE} 
		fi
	done
	cd ${ExHome}
} # end CopyEngSave()

function ManageMonit() {
	action=$1
	service1=$2
	service2=$3
	case $action in
		"stop") 
			trigger="Running"
			endState="Stopped";;
		"start")
			trigger="Not"
			endState="Running";;
	esac
	for s in ${service1} ${service2}
	{
		if sudo monit summary  $s|grep -iq ${trigger} 
		then
			echo "$s NOT ${endState}"
			echo "${action} $s"
			sudo monit ${action} $s
		else
			echo "$s ${endState}"
		fi
	}
} #end ManageMonit()

function FixExodusPerms() {
	sudo ${ExHome}/app/genperm.sh ${ExHome}
} # end FixExodusPerms()


function SetupDirs() {
	cd ${ExHome}
	if [ -d Engine.sav ]
	then
		echo "Saved Engine Directory exists: ${ExHome}/Engine.sav"
	else
		echo "Move Engine to Engine.sav"
		mv Engine Engine.sav
	fi

	if [ -d GenesisMcp ]
	then
		echo "GenesisMcp directory exists: ${ExHome}/GenesisMcp"
	else
		mkdir -p GenesisMcp
	fi

	if [ -h Engine ]
	then
		echo -e "Engine symlink exists:\n $(ls -l ${ExHome}/Engine)"
	else
		echo "Create Engine symlink"
		ln -s GenesisMcp Engine
	fi

	if [ -e .vs-debugger ] 
	then
		echo "debug directory exists: ${ExHomeDbg}"
	else
		echo "Create exodus debug directory"
		sudo mkdir ${ExHomeDbg}
	fi

	if sudo test -e ${RootDbg}
	then
		echo "root debug directory exists: ${RootDbg}"
	else
		echo "Create root debug directory"
		sudo mkdir ${RootDbg}
	fi
} # end SetupDirs()

function WaitForVsBuildDeploy() {
	echo '================================================'
	echo 'Ready for "build & deploy" from Visual Studio'
	echo 'When that is complete, return here an hit enter.'
	echo '================================================'

	read -p "Is build & deploy completed? continue" ans

} # WaitForVsBuildDeploy()

function Usage() {
	prog=${0##*/}
	echo "${prog} -[c|u|i|F|h]"
	echo "	c	Remove VS delivered debug directories to trigger new download"
	echo "	u	Update to prepare for subsequent build, skips setup"
	echo "	i	Initialize first time debugging"
	echo "	F	Restore system to pre-debugging state"
	echo "	h	This message"
	exit 1
} #end Usage()

function ProductionReset() {
	tmpFile=$(mktemp)
	ManageMonit stop engine exoduscmain 
	echo "Remove debug systems from ${HOSTS}"
	grep -v \
	-e "Visual Studio" -e "${AKA}" -e "${VSDBG}" -e "${VSDBGblob}" \
	-e "${DOTNETblob}" ${HOSTS} > ${tmpFile}
	sudo mv ${tmpFile} ${HOSTS}
	sudo chmod 644 ${HOSTS}
	echo "Restore Engine directory"
	rm -f ${ExHome}/Engine
	rm -rf ${ExHome}/GenesisMcp
	mv ${ExHome}/Engine.sav ${ExHome}/Engine
	CleanDbgDirs
	ManageMonit start exoduscmain engine 
} #end ProductionReset()

function Ready() {
	echo '===================================================='
	echo 'Ready to debug from Visual Studio via attach process'
	echo '===================================================='
} #end Ready()

Init

if [ ${#} -lt 1 ]; then
	Usage
fi

while getopts "cuiFh" arg
do
case ${arg} in
	c)	CleanDbgDirs
		exit
        ;;
	u)	ManageMonit stop engine exoduscmain 
		SetupDirs
		WaitForVsBuildDeploy
		CopyEngSave
		FixExodusPerms
		ManageMonit start exoduscmain engine 
		Ready
        ;;
	i)	ManageMonit stop engine exoduscmain 
		CleanDbgDirs
		UpdateHosts
		SetupDirs
		WaitForVsBuildDeploy
		CopyEngSave
		FixExodusPerms
		ManageMonit start exoduscmain engine 
		Ready
	;;
	F)	
		ProductionReset
		exit
	;;    
	*)	Usage
esac
done
