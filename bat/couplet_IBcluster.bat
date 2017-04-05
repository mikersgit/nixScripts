;; batch file to open putty sessions on several machines 
#E9s01 – 10.30.28.1  192.168.28.1 (root/hpinvent)
#E9s02 – 10.30.28.2  192.168.28.2 (root/hpinvent)
#E9s03 – 10.30.28.3  192.168.28.3 (root/hpinvent)
#E9s04 – 10.30.28.4  192.168.28.4 (root/hpinvent)
#Management Console https://10.30.28.201/fusion/resources/window.html

echo 10.30.28.1 >> seq
echo 10.30.28.2 >> seq
echo 10.30.28.3 >> seq
echo 10.30.28.4 >> seq
for /F %%i in (seq) do start "title"  "c:\Program Files\PuTTY\putty.exe"  -X root@%%i -pw hpinvent
del seq
