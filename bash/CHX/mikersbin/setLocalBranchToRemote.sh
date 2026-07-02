#!/bin/bash
# if local branch is deverged from origin, and desire is to make local == origin
#
curBranch=$(git branch --show-current)
echo "WARNING: this will overwrite any local changes. Stash any changes you want to keep."
read -p "Continue with reset of $curBranch to origin/$curBranch? [N]|Y " ans
if [[ ${ans} =~ [Yy] ]] ;then
	git reset --hard origin/${curBranch}
else
	echo "No changes made. Top commit in local branch is"
	git log -1
fi
