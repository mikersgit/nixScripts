#!/bin/bash

FS='/fs1_40' # file system mount point
node2='10.30.236.195'

TO=5
(( ${#} == 1 )) && TO=${1}

#
# print banner with stars
#
function msg(){
	local cnt=${#1};local sline='';local c
	# create line of stars 4 longer than length of first argument to msg
	for ((c=1;c<=(cnt+4);c++)); { sline=${sline}'*'; }
	echo -e "\n\t${sline}\n\t* ${@}\n\t${sline}\n"
} # end msg()

function mkfiles() {
    local dir="${1}"
    local seg=$2   # segment on which to create files
    local fnode=$3 # node from which files are made
    local cnt=$4 # node from which files are made
    (( ${#} == 4 )) && dir=${dir}_${4}
    msg "Create files in ${dir} on segment ${seg}"
    for ((i=1;i<=20;i++))
    {
        fpth="${FS}/${dir}/fileN${fnode}_${i}"
        ibtouch -seg ${seg} ${fpth}
        echo $(date) >> ${fpth}
    }
} # end mkfiles

# arg1 = name; arg2 = node ; arg3 = count; ; arg4 = 'R'emote ssh
function mkdirs() {
    local dir=${1}
    local how=""
    (( ${#} == 4 )) && how="ssh ${node2}"
    (( ${#} > 1 )) && dir=${dir}_${3}
    msg "Create ${dir} on node ${2}"
    eval ${how} "mkdir ${FS}/${dir}"
}

mkdirs node1Dir 1 0
echo "Stay in ${FS} for next step"
read -t ${TO} -p "Node 1 Dir shows up? " ans

mkdirs node1Dir 1 1
echo "Stay in ${FS} for next step"
read -t ${TO} -p "Node 1 Dir 2 shows up? " ans

mkdirs node2Dir 2 0 R
echo "change to node 1 directory befor answering"
read -t ${TO} -p "Node 2 Dir shows up? " ans

mkdirs node2Dir 1 1
echo "Stay in ${FS} for next step"
read -t ${TO} -p "Node 1 Dir 3 shows up? " ans

mkfiles node1Dir 1 1 0
echo "change to node 2 directory befor answering"
read -t ${TO} -p "20 files show up in node1dir? " ans

mkfiles node2Dir 2 2 0
echo "change to node 1 directory befor answering"
read -t ${TO} -p "20 files show up in node2dir? " ans

mkfiles node1Dir 2 2 1
echo "change to ${FS} directory befor answering"
read -t ${TO} -p "20 files show up in node1dir? " ans

msg "Remove 3rd dir on node 1"
rm -rf ${FS}/node1Dir_1
read -t ${TO} -p "Node 1 Dir 3 disappear? " ans
