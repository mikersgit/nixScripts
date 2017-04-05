echo login as BugzillaCloningAutomation@hp.com
echo CloningBugsIsFun!
echo off

rem Releases for which to make targets
echo Possible release targets
echo 65maint Halo Astra-Maint Atlas future
set rel=c:\Users\mwroberts\Desktop\rel
rem del %rel%
rem echo 65maint >> %rel%
rem echo Halo >> %rel%
rem echo Astra-Maint >> %rel%
rem echo Atlas >> %rel%
rem echo future >> %rel%
rem
rem BugzillaCloningAutomation@hp.com
rem CloningBugsIsFun!
rem
rem batch file to open webtabs for each bug in a file
rem assumes each line of file is 'bugnumber component'
rem e.g. '55555 SMB' or '55555 NFS'
rem
set src=c:\Users\mwroberts\Desktop\bugs
set prog="c:\Program Files (x86)\Mozilla Firefox\firefox.exe"
set ieprog="C:\Program Files (x86)\Internet Explorer\iexplore.exe"
set cloneUrl=https://bugzilla.houston.hp.com:1181/bugzilla/enter_bug.cgi?product=Protocols-
set bugUrl=https://bugzilla.houston.hp.com:1181/bugzilla/show_bug.cgi?id=
type %rel%
start "IE" %ieprog%
rem timeout /T 4
pause
echo ***************************
echo ******** [Master] **********
echo ***************************
for /F  %%i in (%src%) do (
	echo %%i
	start "bug" %ieprog% %bugUrl%%%i
)

pause

for /F %%k in (%rel%) do (
   echo ********** %%k **********
   for /F "tokens=1,2" %%i in (%src%) do (
	rem echo %%i %%j %%k
	rem For long lists of bugs use the timeout to not overrun IE
	rem redirect to NULL to not print to screen
	timeout /T 1 > nul
	echo =%%i, %%k
 	start "title" %ieprog% "%cloneUrl%%%j&cloned_bug_id=%%i"
   )
   pause
)

pause
