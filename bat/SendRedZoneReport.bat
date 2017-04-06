rem echo off
rem batch file to send redzone report
setlocal EnableDelayedExpansion

set excel="C:\Program Files (x86)\Microsoft Office\Office15\EXCEL.EXE"
set outlook="C:\Program Files (x86)\Microsoft Office\Office15\OUTLOOK.EXE"
rem
rem Use local contact defined in Outlook/contacts to represent many names
rem instead of having to have a huge list here.
rem
set to=michael.roberts@hpe.com;protRZreport
set targ=c:\Users\mwroberts\Documents\bugs\RedZoneStatus.xlsm
rem call c:\Users\mwroberts\Desktop\bats\RZBugReport.bat
start "excel" %excel% "%targ%" 
set dt=''
pause
for /F "tokens=1,2" %%i in ('date /T') do (
	set dt=%%i %%j
	echo date: !dt!
)
start "outlook" %outlook% /a "%targ%" /c ipm.note /m "%to%&subject=Protocols RedZone Report (!dt!)"

rem pause
