;; batch file to open putty sessions on several machines 
;; vip is 10.30.252.44
echo 10.30.242.20 >> seq
echo 10.30.242.21 >> seq
for /F %%i in (seq) do start "title"  "c:\Program Files (x86)\PuTTY\putty.exe"  -X root@%%i -pw hpinvent
del seq
