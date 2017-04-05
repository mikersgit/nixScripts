rem echo off
rem batch file to copy waiver template for each bug in a file
set relDir=Unity120
set word="C:\Program Files (x86)\Microsoft Office\Office15\WINWORD.EXE"
set src=c:\Users\mwroberts\Desktop\bugs
set tmpl=c:\Users\mwroberts\Documents\bugs\%relDir%\"WaiverTemplate.docx"
set targ=c:\Users\mwroberts\Documents\bugs\%relDir%\"Protocols_"

for /F %%i in (%src%) do (
	copy %tmpl% %targ%%%i.docx
	start "word" %word% %targ%%%i.docx
	timeout /T 1 > nul
)
pause
