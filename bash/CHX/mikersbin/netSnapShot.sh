#!/bin/bash
#
# show network IP active connections, and open files of smarten processes
#

bner='=============================='
function banner() {
	msg=${1}
	echo -e "\t${bner}\n\t${msg}\n\t${bner}"
}
banner "netstat w/o servers"
netstat -tupw4
banner "netstat servers"
netstat -tupw4l
banner "open network files"
lsof -i
for i in hmi.qt5 ExodusCmain.exe dotnet nginx
{
	banner "open ${i} files"
	lsof -c ${i} |grep -v -e \.dll$ -e arm -e \.so\. -e \.so$ -e \/null -e pipe -e \/zero -e "\ cwd\ " -e "\ rtd\ "
}

