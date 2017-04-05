rem echo off
rem batch file to copy PRB/CRB template for each bug in a file

set word="C:\Program Files (x86)\Microsoft Office\Office15\WINWORD.EXE"
set src=c:\Users\mwroberts\Desktop\bugs
set tmpl=c:\Users\mwroberts\Documents\bugs\UnityMain102\"PRBtemplate.rtf"
set targ=c:\Users\mwroberts\Documents\bugs\UnityMain102\"PRB_"

for /F %%i in (%src%) do (
	copy %tmpl% %targ%%%i.rtf
	start "word" %word% %targ%%%i.rtf
	timeout /T 1 > nul
)
pause
