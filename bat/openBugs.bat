echo off
rem batch file to open webtabs for each bug in a file

set src=c:\Users\mwroberts\Desktop\bugs
set prog="c:\Program Files (x86)\Mozilla Firefox\firefox.exe"
rem set ieprog="C:\Program Files (x86)\Internet Explorer\iexplore.exe"
set bugUrl=https://bugzilla.houston.hpecorp.net:1181/bugzilla/show_bug.cgi?id=
for /F %%i in (%src%) do start "title" %prog% %bugUrl%%%i
rem for /F %%i in (%src%) do start "title" %ieprog% %bugUrl%%%i
