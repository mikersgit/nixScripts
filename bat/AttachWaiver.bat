rem delayed expansion fixes the problem of not getting cummulative string
rem built for bug summary list in for loop
rem
setlocal EnableDelayedExpansion
echo off
rem batch file to open webtabs for each bug in a file

set word="C:\Program Files (x86)\Microsoft Office\Office15\WINWORD.EXE"
set targ=c:\Users\mwroberts\Documents\bugs\Unity110\"BugID_Prot_"
set src=c:\Users\mwroberts\Desktop\bugs
set prog="c:\Program Files (x86)\Mozilla Firefox\firefox.exe"
rem set ieprog="C:\Program Files (x86)\Internet Explorer\iexplore.exe"
rem URL for bug detail tab per bug
set bugUrl=https://bugzilla.houston.hp.com:1181/bugzilla/show_bug.cgi?id=
set attachUrl=https://bugzilla.houston.hp.com:1181/bugzilla/attachment.cgi?bugid=
set cgiAction="&action=enter"
rem URL for bug summary page with all bugs listed
set SumBugUrl=https://bugzilla.houston.hp.com:1181/bugzilla/buglist.cgi?quicksearch=
for /F %%i in (%src%) do (
	start "bug" %prog% %bugUrl%%%i
	start "word" %word% %targ%%%i.docx
	start "attach" %prog% %attachUrl%%%i%cgiAction%
	echo Waiver form attachment
	pause
	rem set TmpSumBugUrl=!SumBugUrl!%%i" "
	rem set SumBugUrl=!TmpSumBugUrl!
)
rem launch summary tab
rem start "title" %prog% !SumBugUrl!
rem pause
rem for /F %%i in (%src%) do start "title" %ieprog% %bugUrl%%%i
https://bugzilla.houston.hp.com:1181/bugzilla/attachment.cgi?bugid=63248&action=enter
