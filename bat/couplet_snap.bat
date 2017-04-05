;; batch file to open putty sessions on several machines whose IP's differ
;; only by the last digit

echo 10.30.36.13 > seq
echo 10.30.36.5 >> seq
echo 10.30.36.6 >> seq
echo 10.30.66.6 >> seq
echo 10.30.66.5 >> seq
echo 10.30.66.4 >> seq

for /F %%i in (seq) do start "title"  "c:\Program Files\PuTTY\putty.exe"  -X root@%%i -pw hpinvent
del seq
