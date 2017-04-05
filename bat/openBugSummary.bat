rem Open only the summary bug list, not the detail list
rem delayed expansion fixes the problem of not getting cummulative string
rem built for bug summary list in for loop
rem
setlocal EnableDelayedExpansion
echo off

set src=c:\Users\mwroberts\Desktop\bugs
set prog="c:\Program Files (x86)\Mozilla Firefox\firefox.exe"
rem set ieprog="C:\Program Files (x86)\Internet Explorer\iexplore.exe"
rem URL for bug summary page with all bugs listed
set SumBugUrl=https://bugzilla.houston.hpecorp.net:1181/bugzilla/buglist.cgi?quicksearch=
for /F %%i in (%src%) do (
	set TmpSumBugUrl=!SumBugUrl!%%i" "
	set SumBugUrl=!TmpSumBugUrl!
)
rem launch summary tab
start "title" %prog% !SumBugUrl!
