#!/bin/bash
#
# create clones from bug list in a file
#

buglist=${1}
confFl=${2}
CmdToRun=${3}
binDir=${HOME}/bin
usage="${0} buglistFile ConfigFile Command[M(aster/clone),C(lone),V(ers)]"
if (( $# < 3 ))
then
	echo "${usage}"
	exit 2
fi
# create master and clone
MastrCloneScr="${binDir}/CombineMasterCloning.sh"
# only create clone
CloneScr="${binDir}/OneClone.sh"
# change version
VersionScr="${binDir}/ChangeVers.sh"
CMD="echo ${usage}"
case ${CmdToRun} in
	[mM]) CMD=${MastrCloneScr};;
	[cC]) CMD=${CloneScr};;
	[vV]) CMD=${VersionScr};;
	*) echo ${usage}
	   exit 2
esac

for b in $(<${buglist})
{
	echo $b $confFl
	${CMD} ${b} ${confFl}
	#${CloneScr} ${b} ${confFl}
}
