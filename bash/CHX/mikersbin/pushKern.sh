#!/bin/bash
ip=192.168.0.61
if [[ $# > 0 ]]
then
   ip=${1}
fi
scpk zImage exodus@${ip}:tmp/.

#!/bin/bash
#port=2730
# key is in .bashrc and set at login
#if [[ ${0} == *scpk ]]
#then
#	scp -i "${key}" -P ${port} ${@}
#else
#	ssh -i "${key}" -p ${port} ${@}
#fi
