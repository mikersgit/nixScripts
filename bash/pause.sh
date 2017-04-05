#!/bin/bash

# Command to pause CRR job, list lp files, resume job
#

pause=0
resume=0
list=0
jobid=0
rhost=''

function usage() {
	echo "usage: ${0##*/} [-j job number] [-i IP] [-prl] "
	echo -e "-j #  Where # is the numeric portion of the jobid. default is first job"
	echo -e "-p    Pause job"
	echo -e "-r    Resume job"
	echo -e "-l    List the lp, and prep files for each seg server."
	echo -e "-i IP IP address of other Seg Server"
	exit 2
} #end usage()

while getopts :j:i:prl OPT; do
    case $OPT in
	p)
                pause=1
	;;j)
		jobid=${OPTARG}
	;;r)
		resume=1
	;;l)
		list=1
	;;i)
		rhost=${OPTARG}
	;;*) usage
    esac
done
shift $[ OPTIND - 1 ]

if (( ! pause && ! resume && ! list ))
then
    list=1
fi

# Can't run on the passive FM (ibrix_* commands give error)
#
if ibrix_fm -i |grep passive
then
    echo "Not the active FM, need to run from the other seg server."
    exit 1
fi

# determine the other hostname
#
if (( ! ${#rhost} ))
then
    rhost=$(ibrix_server -l |grep -v -e SERV -e '---' -e $(hostname)|awk '{print $1}')
fi

#assumes only one job running
if ((! jobid))
then
 jobid=$(ibrix_cfrjob -l | awk '$1 ~ /^cfr/ {sub("-"," ");print $2}')
fi

 #record current job files
 # remote
 echo -e "${rhost}\n"
 ssh ${rhost} "ls -lrt /var/log/cfr/${jobid}/[lp]*"

 # local
 echo -e "local\n"
 ls -lrt /var/log/cfr/${jobid}/[lp]*


# if 'list' then list only, don't call pause
if ((list))
then
    # done exit
    exit
else
    if ((resume))
    then
        # resume the job
        ibrix_cfrjob -r -n cfr-${jobid}
    else
        # pause the job
        ibrix_cfrjob -p -n cfr-${jobid}
    fi
    ibrix_cfrjob -l
fi

