# --- NEON COLORS (PowerShell Style) ---
$Host.UI.RawUI.WindowTitle = "🕹️ MYRIENT ARCHIVE TOOL: PS-EDITION 🕹️"

$CYAN    = "`e[0;36m"
$MAGENTA = "`e[0;35m"
$GREEN   = "`e[0;32m"
$RED     = "`e[0;31m"
$YELLOW  = "`e[1;33m"
$BLUE    = "`e[1;34m"
$NC      = "`e[0m"

# --- CONFIGURATION ---
$REMOTE     = "myrient:"
$LOCAL_BASE = "./"
$LIST_FILE  = "download.txt"
$LOG_FILE   = "rclone_log.txt"

Clear-Host
Write-Host -ForegroundColor Magenta "╔════════════════════════════════════════════════════════╗"
Write-Host -ForegroundColor Cyan    "║      🧊  MYRIENT ARCHIVE TOOL: POWERSHELL v1.0  🧊    ║"
Write-Host -ForegroundColor Magenta "╚════════════════════════════════════════════════════════╝"
Write-Host -ForegroundColor Yellow  "DATE: $(Get-Date -Format 'MM/dd/yy')  TIME: $(Get-Date -Format 'HH:mm:ss')"

# Check if the list exists
if (-not (Test-Path $LIST_FILE)) {
    Write-Host -ForegroundColor Red "❌ ERROR: File $LIST_FILE not found!"
    exit
}

# --- DOWNLOAD LOOP ---
Get-Content $LIST_FILE | ForEach-Object {
    $line = $_.Trim()

    # Skip empty lines and comments
    if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith("#")) { return }

    # Path handling: Remove trailing slash for rclone conformity
    $dir = $line.TrimEnd('/')

    Write-Host ""
    Write-Host -ForegroundColor Blue "➔ MISSION: Checking Update for" -NoNewline
    Write-Host -ForegroundColor Green " $dir"
    Write-Host -ForegroundColor Magenta "----------------------------------------------------------"

    # THE RCLONE COMMAND
    # In PowerShell we must pass arguments cleanly.
    # We use an array (@args) to avoid escaping problems with [!].
    $rcloneArgs = @(
        "copy",
        "${REMOTE}${dir}",
        "${LOCAL_BASE}${dir}",
        "--multi-thread-streams", "0",
        "--transfers", "6",
        "--checkers", "10",
        "--update",
        "--modify-window", "2s",
        "--size-only",
        "--user-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
        "--buffer-size", "32M",
        "--use-mmap",
        "--stats", "0.5s",
        "--stats-file-name-length", "30",
        "-P",
        "--log-file", $LOG_FILE,
        "--log-level", "INFO"
    )

    # Execute rclone
    & rclone $rcloneArgs

    # Check exit status
    if ($LASTEXITCODE -eq 0) {
        Write-Host -ForegroundColor Green "✅ MISSION COMPLETE: $dir"
    } else {
        Write-Host -ForegroundColor Red "❌ ERROR IN DATASET: $dir (Code: $LASTEXITCODE)"
        Start-Sleep -Seconds 3
    }
    Write-Host -ForegroundColor Magenta "----------------------------------------------------------"
}

Write-Host ""
Write-Host -ForegroundColor Yellow "=========================================================="
Write-Host -ForegroundColor Cyan   "    🏁 ARCHIVE SYNC COMPLETE - INSERT COIN 🏁"
Write-Host -ForegroundColor Yellow "=========================================================="
