rem echo off
rem batch file to send redzone report
setlocal EnableDelayedExpansion

set excel="C:\Program Files (x86)\Microsoft Office\Office15\EXCEL.EXE"
set outlook="C:\Program Files (x86)\Microsoft Office\Office15\OUTLOOK.EXE"
rem
rem Use local contact defined in Outlook/contacts to represent many names
rem instead of having to have a huge list here.
rem
set to=StAttScrubReportTO
set cc=StAttScrubReportCC
set targ=C:\Users\mwroberts\Documents\bugs\FilePersona160\Scrub_Azha_RZ_bugs.xlsm
rem call c:\Users\mwroberts\Desktop\bats\RZBugReport.bat
rem start "excel" %excel% "%targ%" 
set dt=''
pause
for /F "tokens=1,2" %%i in ('date /T') do (
	set dt=%%i %%j
	echo date: !dt!
)
start "outlook" %outlook% /a "%targ%" /c ipm.note /m "%to%&cc=%cc%&subject=File Persona Bug status (!dt!)"

rem pause
