rem echo off
rem batch file to open existing PRB forms for each bug in a file

set word="C:\Program Files (x86)\Microsoft Office\Office15\WINWORD.EXE"
set src=c:\Users\mwroberts\Desktop\bugs
set targ=c:\Users\mwroberts\Documents\bugs\UnityMain102\"PRB_"

for /F %%i in (%src%) do (
	start "word" %word% %targ%%%i.rtf
	timeout /T 2 > nul
)
pause
