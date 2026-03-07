@echo off
REM Windows batch script for downloading from Myrient using rclone
REM Optimized for Sonderzeichen [!] and Btrfs/NTFS consistency

setlocal disabledelayedexpansion

REM --- ENABLE ANSI COLOR SUPPORT (Windows 10+) ---
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
    set "ESC=%%b"
)

REM --- NEON COLORS ---
set "CYAN=%ESC%[0;36m"
set "MAGENTA=%ESC%[0;35m"
set "GREEN=%ESC%[0;32m"
set "RED=%ESC%[0;31m"
set "YELLOW=%ESC%[1;33m"
set "BLUE=%ESC%[1;34m"
set "NC=%ESC%[0m"

REM --- CONFIGURATION ---
set "REMOTE=myrient:"
set "LOCAL_BASE=.\"
set "LIST_FILE=download.txt"
set "LOG_FILE=rclone_log.txt"

REM Check if rclone is available
where rclone >nul 2>&1
if errorlevel 1 (
    echo %RED%Error: rclone not found!%NC%
    pause
    exit /b 1
)

cls
echo %MAGENTA%╔════════════════════════════════════════════════════════╗%NC%
echo %MAGENTA%║%NC%%CYAN%      🧊  MYRIENT ARCHIVE TOOL: BATCH-BEEF v7.0  🧊    %NC%%MAGENTA%║%NC%
echo %MAGENTA%╚════════════════════════════════════════════════════════╝%NC%
echo %YELLOW%DATE:%NC% %date%  %YELLOW%TIME:%NC% %time:~0,8%
echo.

if not exist "%LIST_FILE%" (
    echo %RED%❌ ERROR: File %LIST_FILE% not found!%NC%
    pause
    exit /b 1
)

REM --- DOWNLOAD LOOP ---
REM We read the file WITHOUT delayed expansion to protect the "!"
for /f "usebackq tokens=* delims=" %%A in ("%LIST_FILE%") do (
    set "line=%%A"
    call :process_line "%%A"
)

echo.
echo %YELLOW%==========================================================%NC%
echo %CYAN%    🏁 ARCHIVE SYNC COMPLETE - INSERT COIN 🏁%NC%
echo %YELLOW%==========================================================%NC%
pause
goto :eof

:process_line
set "dir=%~1"

REM Skip empty lines and comments
if "%dir%"=="" goto :eof
if "%dir:~0,1%"=="#" goto :eof

REM Remove trailing slashes (Forward and Backward)
:trim_slash
if "%dir:~-1%"=="/" set "dir=%dir:~0,-1%" & goto :trim_slash
if "%dir:~-1%"=="\" set "dir=%dir:~0,-1%" & goto :trim_slash

REM Convert backslashes to forward slashes
set "dir=%dir:\=/%"

echo.
echo %BLUE%➔ MISSION:%NC% Checking Update for %GREEN%%dir%%NC%
echo %MAGENTA%----------------------------------------------------------%NC%

REM THE "BEEF" COMMAND
REM We use "copy" for both files and dirs, rclone handles the rest.
REM IMPORTANT: We use quotes around variables to protect [!]
rclone copy ^
    "%REMOTE%%dir%" ^
    "%LOCAL_BASE%%dir%" ^
    --multi-thread-streams 0 ^
    --transfers 6 ^
    --checkers 10 ^
    --update ^
    --modify-window 2s ^
    --size-only ^
    --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" ^
    --buffer-size 32M ^
    --use-mmap ^
    --stats 0.5s ^
    --stats-file-name-length 30 ^
    -P ^
    --log-file="%LOG_FILE%" ^
    --log-level INFO

if %errorlevel% equ 0 (
    echo %GREEN%✅ MISSION COMPLETE: %dir%%NC%
) else (
    echo %RED%❌ ERROR IN DATASET: %dir%%NC%
    timeout /t 3 /nobreak >nul
)
echo %MAGENTA%----------------------------------------------------------%NC%
goto :eof
