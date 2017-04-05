echo login as BugzillaCloningAutomation@hp.com
echo CloningBugsIsFun!
echo off
rem
rem BugzillaCloningAutomation@hp.com
rem CloningBugsIsFun!
rem
rem batch file to open webtabs for each bug in a file
rem assumes each line of file is 'bugnumber component'
rem e.g. '55555 SMB' or '55555 NFS'
rem
set src=c:\Users\mwroberts\Desktop\bugs
set amp="%26"
set prog="c:\Program Files (x86)\Mozilla Firefox\firefox.exe"
set ieprog="C:\Program Files (x86)\Internet Explorer\iexplore.exe"
rem set cloneUrl=https://bugzilla.houston.hp.com:1181/bugzilla/enter_bug.cgi?product=Protocols-SMB
set cloneUrl=https://bugzilla.houston.hp.com:1181/bugzilla/enter_bug.cgi?product=Protocols-
set bugUrl=https://bugzilla.houston.hp.com:1181/bugzilla/show_bug.cgi?id=
rem had to put '&' parameter in the for so batch wouldn't strip it out
start "IE" %ieprog%
rem timeout /T 4
pause
echo ***************************
echo ********** Astra **********
echo ***************************
for /F "tokens=1,2" %%i in (%src%) do echo %%i %%j & start "bug" %ieprog% %bugUrl%%%i & pause & echo =%%i, Astra & start "title" %ieprog% "%cloneUrl%%%j&cloned_bug_id=%%i"

echo ***************************
echo ********** Atlas **********
echo ***************************
for /F "tokens=1,2" %%i in (%src%) do pause & echo =%%i, Atlas & start "title" %ieprog% "%cloneUrl%%%j&cloned_bug_id=%%i"

pause
