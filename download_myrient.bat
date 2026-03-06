@echo off
REM Windows batch script for downloading from Myrient using rclone
REM Requires rclone to be installed and configured with remote "myrient:"

setlocal disabledelayedexpansion

set "REMOTE=myrient:"
set "LOCAL_BASE=.\"
set "LIST_FILE=download.txt"
set "RCLONE_LOG=rclone_log.txt"
set "SCRIPT_LOG=download_log.txt"

REM Check if rclone is available
where rclone >nul 2>&1
if errorlevel 1 (
    echo Error: rclone not found! Please install rclone first.
    pause
    exit /b 1
)

if not exist "%LIST_FILE%" (
    echo Error: %LIST_FILE% not found!
    pause
    exit /b 1
)

for /f "usebackq tokens=* delims=" %%A in ("%LIST_FILE%") do (
    set "line=%%A"

    REM Enable delayed expansion only for processing, not for reading
    setlocal enabledelayedexpansion

    REM Skip empty lines
    if "!line!"=="" (
        endlocal
        goto :continue
    )

    REM Skip comment lines starting with #
    echo !line! | findstr /b /c:"#" >nul
    if !errorlevel! equ 0 (
        endlocal
        goto :continue
    )

    REM Clean up the directory path
    set "dir=!line!"

    REM Trim leading/trailing whitespace
    for /f "tokens=* delims= " %%B in ("!dir!") do set "dir=%%B"

    REM Remove all trailing slashes (/ and \)
    :trim_slash
    if "!dir:~-1!"=="/" set "dir=!dir:~0,-1!" & goto :trim_slash
    if "!dir:~-1!"=="\" set "dir=!dir:~0,-1!" & goto :trim_slash

    REM Convert backslashes to forward slashes for consistency
    set "dir=!dir:\=/!"

    REM Detect if it's a file (has extension) or directory
    set "is_file=0"
    for %%F in ("!dir!") do (
        set "ext=%%~xF"
        if not "!ext!"=="" set "is_file=1"
    )

    echo ======================================== >> "%SCRIPT_LOG%"
    echo Starting: !dir! >> "%SCRIPT_LOG%"
    echo Time: %date% %time% >> "%SCRIPT_LOG%"
    echo ======================================== >> "%SCRIPT_LOG%"

    echo.
    echo ========================================
    echo Starting: !dir!
    echo Time: %date% %time%
    echo ========================================

    REM Use copyto for files, copy for directories
    if "!is_file!"=="1" (
        rclone copyto ^
            "%REMOTE%!dir!" ^
            "%LOCAL_BASE%!dir!" ^
            --multi-thread-streams 0 ^
            --size-only ^
            --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" ^
            --buffer-size 32M ^
            --update ^
            -P ^
            --log-file="%RCLONE_LOG%" ^
            --log-level INFO
    ) else (
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
            --log-file="%RCLONE_LOG%" ^
            --log-level INFO
    )

    set "exitcode=!errorlevel!"
    echo Finished: !dir! (Exit Code: !exitcode!) >> "%SCRIPT_LOG%"
    echo. >> "%SCRIPT_LOG%"
    endlocal

    :continue
)

echo ======================================== >> "%SCRIPT_LOG%"
echo All downloads completed. >> "%SCRIPT_LOG%"
echo Time: %date% %time% >> "%SCRIPT_LOG%"
echo ======================================== >> "%SCRIPT_LOG%"

echo.
echo ========================================
echo All downloads completed.
echo ========================================
echo.
pause
