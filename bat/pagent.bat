echo OFF
rem create a key using puttygen.exe, and put the public part of the key pair
rem on machines you want to ssh to w/o password. At startup start the putty
rem agent, provide the passphrase for the key once, and then you can access
rem machines that have your public key.
REM set dir="c:/Users/Administrator.MROBERTS15/Desktop/key"
set dir="c:/Users/mwroberts/Desktop/key"
start "title" "C:\Program Files (x86)\PuTTY\pageant.exe" %dir%/pcPriv.ppk
exit
