#!/bin/bash

# --- NEON COLORS (Arcade Cabinet Style) ---
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# --- CONFIGURATION ---
REMOTE="myrient:"
LOCAL_BASE="./"
LIST_FILE="download.txt"
LOG_FILE="rclone_log.txt"

# --- SYSTEM-TUNING & TABBY-FIX ---
# Forces rclone to assume more space for progress bars
export COLUMNS=160
export TERM=xterm-256color
# Kernel-Fix: Reuse sockets immediately (Intel-PC)
sudo sysctl -w net.ipv4.tcp_tw_reuse=1 > /dev/null 2>&1

clear
echo -e "${MAGENTA}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║${NC}${CYAN}      🧊  MYRIENT ARCHIVE TOOL: BTRFS-NEON v6.1  🧊    ${NC}${MAGENTA}║${NC}"
echo -e "${MAGENTA}╚════════════════════════════════════════════════════════╝${NC}"
echo -e "${YELLOW}DATE:${NC} $(date +%D)  ${YELLOW}TIME:${NC} $(date +%H:%M:%S)"

# Check if the list exists
if [[ ! -f "$LIST_FILE" ]]; then
    echo -e "${RED}❌ ERROR: File $LIST_FILE not found!${NC}"
    exit 1
fi

# --- DOWNLOAD LOOP ---
while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" == \#* ]] && continue

    # Clean path (removes trailing slash)
    dir="${line%/}"

    echo -e "\n${BLUE}➔ MISSION: Checking Update for${NC} ${GREEN}$dir${NC}"
    echo -e "${MAGENTA}----------------------------------------------------------${NC}"

    # THE ULTIMATE BTRFS-BEEF COMMAND
    # --update: Only download newer files from server
    # --modify-window 2s: Tolerance for Btrfs timestamps (prevents endless downloads)
    # --size-only: Additional file size check
    # -P: Enable progress bar graphics
    rclone copy \
        "${REMOTE}${dir}/" \
        "${LOCAL_BASE}${dir}/" \
        --multi-thread-streams 0 \
        --transfers 6 \
        --checkers 10 \
        --update \
        --modify-window 2s \
        --size-only \
        --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" \
        --buffer-size 32M \
        --update \
        --use-mmap \
        --stats 0.5s \
        --stats-file-name-length 30 \
        -P \
        --log-file="$LOG_FILE" \
        --log-level INFO

    # Check exit status
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ MISSION COMPLETE: $dir${NC}"
    else
        echo -e "${RED}❌ ERROR IN DATASET: $dir${NC}"
        # Short pause on error (calm down network stack)
        sleep 3
    fi
    echo -e "${MAGENTA}----------------------------------------------------------${NC}"

done < "$LIST_FILE"

echo -e "\n${YELLOW}==========================================================${NC}"
echo -e "${CYAN}    🏁 ARCHIVE SYNC COMPLETE - INSERT COIN TO RESTART 🏁${NC}"
echo -e "${YELLOW}==========================================================${NC}"
