rem echo off
rem batch file to open existing waiver forms for each bug in a file

set relDir=Unity120
set word="C:\Program Files (x86)\Microsoft Office\Office15\WINWORD.EXE"
set src=c:\Users\mwroberts\Desktop\bugs
set targ=c:\Users\mwroberts\Documents\bugs\%relDir%\"Protocols_"

for /F %%i in (%src%) do (
	start "word" %word% %targ%%%i.docx
	timeout /T 2 > nul
)
pause
