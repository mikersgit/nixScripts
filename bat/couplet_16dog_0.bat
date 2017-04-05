;; batch file to open putty sessions on several machines 

echo 16.125.127.75 >> seq
echo 16.125.127.76 >> seq
for /F %%i in (seq) do start "title"  "c:\Program Files (x86)\PuTTY\putty.exe"  -X mwroberts@%%i -i "c:\Users\mwroberts\Desktop\key\pcPriv.ppk" -pw hpinvent

rem for /F %%i in (seq) do start "title"  "c:\Program Files (x86)\PuTTY\putty.exe"  -X root@%%i -pw hpinvent
del seq
