rem batch file to open daily bug tracking spreadsheets
rem echo off
setlocal EnableDelayedExpansion

set EXCEL="C:\Program Files (x86)\Microsoft Office\Office15\EXCEL.EXE"
set srcdir=C:\Users\mwroberts\Documents\bugs
set srcfile=%srcdir%\bugSheets.txt 
set files=
for /F %%i in (%srcfile%) do (
	rem Note there is a space at the end of the next line
	set tmpfl=!files!%srcdir%\%%i 
	set files=!tmpfl!
)
rem echo !files!
start "excel" %EXCEL% /e !files!
rem pause
