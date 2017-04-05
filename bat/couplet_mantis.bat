;; batch file to open putty sessions on several machines whose IP's differ
;; only by the last digit

echo 10.30.243.8 > seq
echo 10.30.243.9 >> seq
echo 10.30.243.10 >> seq

for /F %%i in (seq) do start "title"  "c:\Program Files (x86)\PuTTY\putty.exe"  -X root@%%i -pw hpinvent
del seq
