rem echo off
rem batch file to copy waiver template for each bug in a file

set outlook="C:\Program Files (x86)\Microsoft Office\Office15\OUTLOOK.EXE"
set src=c:\Users\mwroberts\Desktop\team.txt
set tmpl=c:\Users\mwroberts\Documents\manage\"TeamAccomplishmentsCrowdSource.xlsx"
set targ=c:\Users\mwroberts\Documents\manage\2015peer\TeamAccomplishmentsCrowdSource_

for /F %%i in (%src%) do (
	rem copy %tmpl% %targ%%%i.xlsx
	start "outlook" %outlook% /a "%targ%%%i.xlsx" /c ipm.note /m "%%i&subject=Crowd source peer review"
	timeout /T 1 > nul
)
pause
