#!/bin/bash

REMOTE="myrient:"
LOCAL_BASE="./"
LIST_FILE="download.txt"
LOG_FILE="rclone_log.txt"

while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" == \#* ]] && continue

    dir="${line%/}"

    echo "========================================" | tee -a "$LOG_FILE"
    echo "Starting: $dir" | tee -a "$LOG_FILE"
    echo "Time: $(date)" | tee -a "$LOG_FILE"
    echo "========================================" | tee -a "$LOG_FILE"

    rclone copy \
        "${REMOTE}${dir}/" \
        "${LOCAL_BASE}${dir}/" \
        --multi-thread-streams 0 \
        --transfers 10 \
        --checkers 20 \
        --size-only \
        --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" \
        --buffer-size 32M \
        --update \
        -P \
        --log-file="$LOG_FILE" \
        --log-level INFO

    echo "Finished: $dir (Exit: $?)" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"

done < "$LIST_FILE"

echo "All downloads completed." | tee -a "$LOG_FILE"
