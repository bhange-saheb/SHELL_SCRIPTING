#!/bin/bash

# Safe strict mode
set -euo pipefail

# Configuration
LOG_FILE="/var/log/userlog"          # Path to your log file (Consider changing to an app-specific path)
MAX_SIZE=100000000                  # Maximum size in bytes (100 MB)
BACKUP_DIR="/var/log/userlog/backups" # Directory to store rotated logs
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")  # Timestamp for backup filename

# Ensure backup directory exists safely
mkdir -p "$BACKUP_DIR"

# Function to rotate log files safely using truncation
rotate_logs() {
    if [ -f "$LOG_FILE" ]; then
        local backup_path="$BACKUP_DIR/userlog_$TIMESTAMP.log"
        echo "[$(date)] Rotating log file: $LOG_FILE"
        
        # 1. Copy the current contents to the backup destination
        cp "$LOG_FILE" "$backup_path"
        
        # 2. TRUNCATE the original file safely without breaking active file descriptors
        cat /dev/null > "$LOG_FILE"
        
        echo "[$(date)] Log file rotated and stored as $backup_path"
    else
        echo "ERROR: Log file $LOG_FILE disappeared during execution." >&2
        return 1
    fi
}

# Cross-platform file size checker (Works on Linux and macOS)
get_file_size() {
    if [ "$(uname)" == "Darwin" ]; then
        stat -f%z "$1"
    else
        stat -c%s "$1"
    fi
}

# Main Execution Flow
if [ -f "$LOG_FILE" ]; then
    FILE_SIZE=$(get_file_size "$LOG_FILE")
    
    if [ "$FILE_SIZE" -gt "$MAX_SIZE" ]; then
        rotate_logs
    else
        echo "Log file size is under control: ${FILE_SIZE} bytes"
    fi
else
    echo "WARNING: Log file $LOG_FILE does not exist. No action taken." >&2
fi