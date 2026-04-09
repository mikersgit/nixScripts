#!/bin/bash
# On a branch, reset the HEAD pointer, then push that pointer so that
# history is now rewritten to omit the commits between the previous HEAD
# and the one you want.
echo 'To UNDO a local only commit (not pushed)
$ git commit -m "Something terribly misguided" # (0: Your Accident)
$ git reset HEAD~                              # (1)
[ edit files as necessary ]                    # (2)
$ git add .                                    # (3)
$ git commit -c ORIG_HEAD                      # (4)
'
echo '
git checkout <branch name>
git log # to determine the hash you want to reset as HEAD
git reset --hard <commit hash> # points HEAD to the selected commit
git log # confirm that you have the commit you want
git push --force-with-lease origin HEAD # force the reset to the branch
'
echo '
 to copy a branch to a new name
 in the branch you want to copy
 git checkout <branch to be copied>
 git branch -c <new name>
 git checkout <new name>
'
echo '
 to move a branch to a new name
 checkout the branch you want to move
 git checkout <branch to be moved>
 git branch -m <new name>
 git push origin head
 git checkout <new name>
 git log
'
