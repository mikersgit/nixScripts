#!/bin/bash
read -p"change list name: " CLN
CL="cl_$$"
svnst | awk '{print $NF}' > ${CL}
vi ${CL}
read -p"Make change list: " ans
if [[ ${ans} = [yY] ]]
then
    svn changelist ${CLN} --targets ${CL}
fi
svnst
