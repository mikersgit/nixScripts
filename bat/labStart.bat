start "title" "C:\Users\mwroberts\Desktop\bats\pagent.bat"
echo "Enter ssh passphrase before putty connections"
pause
start "rhel"  "C:\Users\mwroberts\Desktop\bats\build55_tmux.bat"
rem start "title" "C:\Users\mwroberts\Desktop\bats\fcovpn.bat"
rem Xwindows on Windows: xming
rem start "title" "C:\Users\mwroberts\Desktop\bats\Xming.bat"
rem echo "Authenticate VPN before mounting ftchome"
rem pause
start "title" "C:\Users\mwroberts\Desktop\bats\ftchome.bat"
start "DogFood" "C:\Users\mwroberts\Desktop\bats\DogFood.bat"
