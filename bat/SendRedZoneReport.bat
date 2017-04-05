rem echo off
rem batch file to send redzone report
setlocal EnableDelayedExpansion

set excel="C:\Program Files (x86)\Microsoft Office\Office15\EXCEL.EXE"
set outlook="C:\Program Files (x86)\Microsoft Office\Office15\OUTLOOK.EXE"
set to=wjeong@hpe.com;michael.roberts@hpe.com;kari.kechter@hpe.com;matthew.dav.bondurant@hpe.com;sung-jun.pak@hpe.com;mike.gaines@hpe.com;matthew.leach3@hpe.com;irina.boyko@hpe.com;james.beck@hpe.com;BigDev;brian.livingston@hpe.com;jeff.bonds@hpe.com;joann.mcintyre@hpe.com;jonathan.seba@hpe.com;andy_sparkes@hpe.com
set targ=c:\Users\mwroberts\Documents\bugs\RedZoneStatus.xlsm
call c:\Users\mwroberts\Desktop\bats\RZBugReport.bat
start "excel" %excel% "%targ%" 
set dt=''
pause
for /F "tokens=1,2" %%i in ('date /T') do (
	set dt=%%i %%j
	echo date: !dt!
)
start "outlook" %outlook% /a "%targ%" /c ipm.note /m "%to%&subject=Protocols RedZone Report !dt!"

rem pause
