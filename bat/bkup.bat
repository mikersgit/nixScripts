set PATH=%PATH%;"C:\Program Files\PuTTY"
set USER=mikers
set SYS=15.238.13.151
set REMOTE=%USER%@%SYS%

set SRC="C:\Documents and Settings\mwroberts\Desktop"
set DEST=Desktop/backups/pcroberts/desktop

set bSRC=Desktop/backups/mwrlinux
set bDEST="C:\Documents and Settings\mwroberts\Desktop\backups\mwrlinux"

set KEY=%SRC%\key\pcPriv.ppk

rem get to Desktop
cd  %SRC%
rem copy from ubunto to pc
pscp.exe -r -p -i %KEY% %REMOTE%:%bSRC%/home/FULL* %bDEST%\home
pscp.exe -r -p -i %KEY% %REMOTE%:%bSRC%/repos/FULL* %bDEST%\repos

rem
rem copy from pc to ubunto
rem

pscp.exe -r -p -i %KEY% *pdf %REMOTE%:%DEST%
pscp.exe -r -p -i %KEY% *htm %REMOTE%:%DEST%
pscp.exe -r -p -i %KEY% *html %REMOTE%:%DEST%
pscp.exe -r -p -i %KEY% *doc %REMOTE%:%DEST%
pscp.exe -r -p -i %KEY% *ppt %REMOTE%:%DEST%
pscp.exe -r -p -i %KEY% *xls %REMOTE%:%DEST%
pscp.exe -r -p -i %KEY% *vsd %REMOTE%:%DEST%
pscp.exe -r -p -i %KEY% *docx %REMOTE%:%DEST%
pscp.exe -r -p -i %KEY% *txt %REMOTE%:%DEST%
pscp.exe -r -p -i %KEY% *bat %REMOTE%:%DEST%
pscp.exe -r -p -i %KEY% *gz %REMOTE%:%DEST%
pscp.exe -r -p -i %KEY% *bz2 %REMOTE%:%DEST%
pscp.exe -r -p -i %KEY% *zip %REMOTE%:%DEST%
pscp.exe -r -p -i %KEY% *rpm %REMOTE%:%DEST%

pscp.exe -r -p -i %KEY% SWinstalls %REMOTE%:%DEST%
pscp.exe -r -p -i %KEY% bats %REMOTE%:%DEST%
