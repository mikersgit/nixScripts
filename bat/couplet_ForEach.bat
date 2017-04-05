;; batch file to open putty sessions on several machines whose IP's differ
;; only by the last digit

echo 0 > seq
echo 1 >> seq
echo 2 >> seq
echo 3 >> seq
echo 4 >> seq
echo 5 >> seq
for /F %%i in (seq) do start "title"  "c:\Program Files\PuTTY\putty.exe"  -X root@10.30.243.10%%i -pw hpinvent
del seq