;; batch file to open putty sessions on several machines 

echo 10.30.237.157 >> seq
echo 10.30.237.158 >> seq
for /F %%i in (seq) do start "title"  "c:\Program Files (x86)\PuTTY\putty.exe"  -X root@%%i -pw hpinvent
del seq
