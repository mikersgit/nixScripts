#!/bin/bash

hst[1]='mwr1-1'
hst[2]='mwr1-2'
share='/fs1_41/d1/d2'
cd ${share}
rIP='10.30.237.158' # IP address of the other node

echo -e "\nclean up from before\n*********"
rm -rf ${share}/fldr1/${hst[1]}*
rm -rf ${share}/fldr1/${hst[2]}*

echo -e "\nstart inotify\n*********"

~/bin/13FebDcnTest fldr1 N  10000 2>&1 > ~/dcn.out &

bpid=$!
echo "inotify pid: ${bpid}"
ps -fp ${bpid}
sleep 4
echo -e "\ncreate 100 files on $(hostname)\n*********"

for ((j=1;j<=100;j++)); { touch fldr1/$(hostname)-${j}; }

echo -e "\ncreate 100 files on ${hst[2]}\n*********"

ssh ${rIP} /root/mkfiles.sh
sync
sleep 3
sync
sleep 3

j=1
for i in ${hst[*]}
{
    echo "number of events for ${i}:"
    cnt[$j]=$(grep ${i} ~/dcn.out | awk '{print $NF}' | sort -u | wc -l)
    echo ${cnt[$j]}
    ((j+=1))
}

if (( ${cnt[1]} != ${cnt[2]} ))
then
    echo -e "\n\t***************\n\t* E R R O R\n\t***************\n"
    tail -5 ~/dcn.out
else
    echo -e "\n\t\t***************\n\t\t* SUCCESS!! \n\t\t***************\n"
fi

kill ${bpid}

# remote script mkfiles.sh looks like:
#
# cd /fs1_41/d1/d2
# for ((j=1;j<=100;j++)); { touch fldr1/$(hostname)${j}; }
