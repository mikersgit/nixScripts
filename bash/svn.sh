#!/bin/bash

BUG="$(echo ${PWD##*bug} | cut -d '/' -f 1)"
sBUG="bug${BUG}"
svnModule='fmt_0'
svnBase='/root/workspace'
svnTrunk="tt/${svnModule}"
svnTrunkUrl="^/trunk/${svnModule}"
svnBranch="${svnBase}/${sBUG}/${svnModule}"
svnBranchUrl="^/branches/private/michael.roberts/${sBUG}/${svnModule}"
revDir="${HOME}/review"

dfile='server_log.conf'
ddir='ias/cluster/conf'
cd ${svnBranch}
svn merge ${svnTrunkUrl}
echo -e "Bug: ${BUG}\nMerging up from trunk" > ci.txt
svn ci -F ci.txt
svn diff ${svnTrunkUrl}/${ddir}/${dfile} \
         ${svnBranchUrl}/${ddir}/${dfile} \
         > ${revDir}/${sBUG}.patch
svn diff --summarize ${svnTrunkUrl} ${svnBranchUrl} > ${revDir}/${sBUG}.sum.diffs

# try to get a clean diff/patch
 cd ${svnBranch}
 svn merge ${svnTrunkUrl}
 echo -e "Bug: ${BUG}\nMerging up from trunk" > ci.txt
 svn ci -F ci.txt 

 svn diff ${svnTrunkUrl} \
         ${svnBranchUrl} |
         tee ${revDir}/${sBUG}.patch |
 ~/bin/cdiff.sh > ${revDir}/${sBUG}_diff.html
