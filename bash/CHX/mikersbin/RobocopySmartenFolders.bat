@echo off
setlocal enabledelayedexpansion

set /p buildNumber="Enter Build Number: "
echo You entered: %buildNumber%

REM Get start time in seconds
call :GetSeconds %time% startSeconds

REM xcopy "C:\CX\Smarten_Sources\6.1.1" "C:\Source Temp Move Folder\6.1.1" /E /I /H /Y /C

robocopy "C:\CX\Smarten_Sources\6.1.1" "C:\Source Temp Move Folder\6.1.1."%buildNumber% /E /MT:8 /XD node_modules .vs .bin bin packages obj /XF *.xz

REM Get end time and calculate elapsed
call :GetSeconds %time% endSeconds
set /a elapsedSeconds=!endSeconds!-!startSeconds!

REM Calculate elapsed time (basic method)
echo.
echo Process completed!
echo Elapsed time: !elapsedSeconds! seconds

pause

goto :eof

:GetSeconds
REM Convert time to total seconds
set time1=%1
for /f "tokens=1-4 delims=:.," %%a in ("%time1%") do (
    set /a hours=%%a
    set /a minutes=%%b  
    set /a seconds=%%c
    set /a centiseconds=%%d
)
set /a %2=hours*3600 + minutes*60 + seconds
goto :eof