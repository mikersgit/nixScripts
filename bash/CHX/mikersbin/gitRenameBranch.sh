#!/bin/bash
OLDBRANCH=$1
NEWBRANCH=$2

echo "rename ${OLDBRANCH} to ${NEWBRANCH}"
read -p "continue? [N]|Y" ans

if [[ $ans = "Y" ]]
then
	git checkout ${OLDBRANCH}
	git branch
	git branch -m ${NEWBRANCH}
	git push origin :${OLDBRANCH} ${NEWBRANCH}
	git pull
	git branch
	git push origin -u ${NEWBRANCH}
fi
