@echo off
REM Windows batch script for downloading from Myrient using rclone
REM Requires rclone to be installed and configured with remote "myrient:"

setlocal enabledelayedexpansion

set "REMOTE=myrient:"
set "LOCAL_BASE=.\"
set "LIST_FILE=download.txt"
set "LOG_FILE=rclone_log.txt"

if not exist "%LIST_FILE%" (
    echo Error: %LIST_FILE% not found!
    pause
    exit /b 1
)

for /f "usebackq tokens=* delims=" %%A in ("%LIST_FILE%") do (
    set "line=%%A"

    REM Skip empty lines
    if "!line!"=="" goto :continue

    REM Skip comment lines starting with #
    echo !line! | findstr /b /c:"#" >nul
    if !errorlevel! equ 0 goto :continue

    REM Remove trailing slash if present
    set "dir=!line!"
    if "!dir:~-1!"=="/" set "dir=!dir:~0,-1!"

    echo ======================================== >> "%LOG_FILE%"
    echo Starting: !dir! >> "%LOG_FILE%"
    echo Time: %date% %time% >> "%LOG_FILE%"
    echo ======================================== >> "%LOG_FILE%"

    echo.
    echo ========================================
    echo Starting: !dir!
    echo Time: %date% %time%
    echo ========================================

    rclone copy ^
        "%REMOTE%!dir!/" ^
        "%LOCAL_BASE%!dir!/" ^
        --multi-thread-streams 0 ^
        --transfers 10 ^
        --checkers 20 ^
        --size-only ^
        --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" ^
        --buffer-size 32M ^
        --update ^
        -P ^
        --log-file="%LOG_FILE%" ^
        --log-level INFO

    echo Finished: !dir! (Exit Code: !errorlevel!) >> "%LOG_FILE%"
    echo. >> "%LOG_FILE%"

    echo Finished: !dir! (Exit Code: !errorlevel!)
    echo.

    :continue
)

echo ======================================== >> "%LOG_FILE%"
echo All downloads completed. >> "%LOG_FILE%"
echo Time: %date% %time% >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"

echo.
echo ========================================
echo All downloads completed.
echo ========================================
echo.
pause
