rem delayed expansion fixes the problem of not getting cummulative string
rem built for bug summary list in for loop
rem
setlocal EnableDelayedExpansion
echo off
rem batch file to open webtabs for each bug in a file

set src=c:\Users\mwroberts\Desktop\bugs
set prog="c:\Program Files (x86)\Mozilla Firefox\firefox.exe"
rem set ieprog="C:\Program Files (x86)\Internet Explorer\iexplore.exe"
rem URL for bug detail tab per bug
set bugUrl=https://bugzilla.houston.hpecorp.net:1181/bugzilla/show_bug.cgi?id=
rem URL for bug summary page with all bugs listed
set SumBugUrl=https://bugzilla.houston.hpecorp.net:1181/bugzilla/buglist.cgi?quicksearch=
for /F %%i in (%src%) do (
	start "title" %prog% %bugUrl%%%i
	set TmpSumBugUrl=!SumBugUrl!%%i" "
	set SumBugUrl=!TmpSumBugUrl!
)
rem launch summary tab
start "title" %prog% !SumBugUrl!
rem pause
rem for /F %%i in (%src%) do start "title" %ieprog% %bugUrl%%%i
