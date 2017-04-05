#!/bin/bash
if (( $# == 0 ))
then
   echo "Provide a process name from which to get the core"
   echo "EG. ${0##*/} ProcName"
   exit 1
else
   cmd=${1}
fi
pid=$(pgrep ${cmd})
cfile=$(mktemp /tmp/core.pid${pid}.${cmd}.$(date '+%Y:%m:%d:%T'))
echo -e "gcore ${cfile}" >gdbcmds
gdb --silent -batch-silent -p ${pid} --command=gdbcmds
delim='================================================================================='
echo -e "\n${delim}\nCore file of ${cmd} (${pid}) is ${cfile}\n$(file ${cfile})\n${delim}\n"
# rm -f gdbcmds
