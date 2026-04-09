#!/bin/bash
function usage(){
	echo "USAGE: ${0##*/} <compilation path> <source tar file web path> <new lib web path>"
 	echo "eg.    ${0##*/} /home/exodus/Exmwr/Exodus https://exodus.center/files/misc/mwr/ExodusCapps.tar.xz-Vxx https://exodus.center/files/misc/mwr/libRIB2.so.1.0-Vxx"
	echo "NB. to get the web paths right click on the web page and 'copy link-address', then paste on command line."
	echo "    The build using "buildLib.sh" echos the compilation path that can be pasted as the first argument"
	exit 1
}

if [ ${#} -lt 3 ]
then
	usage
fi

CompilationPath=${1}
shift 1
WWWpaths=(${@})

for f in ${WWWpaths[@]}
do
	FileName=${f##*/}
	# switch to non-TLS http because certs on units not valid
	f=$(echo ${f} | sed 's/https/http/')
	[ -e ${FileName} ] && rm ${FileName}
	wget ${f}
	ls -l ${FileName}
	if echo ${FileName} |grep -q tar
	then
		SrcTarPath=${PWD}/${FileName}
	fi
done

echo -e  "\n\t========================================"
echo -e "\tExtracting source to ${CompilationPath}"
echo -e  "\t========================================"

mkdir -p ${CompilationPath}
tar -C ${CompilationPath} -xf ${SrcTarPath}

echo -e "\n\t=========================================="
echo -e "\tVerify these lines are in ${HOME}/.gdbinit"
echo -e "\t=========================================="

echo "add-auto-load-safe-path ${HOME}/.gdbinit"
echo "set directories ${CompilationPath}"
echo "set verbose off"
