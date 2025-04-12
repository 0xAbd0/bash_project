#!/bin/bash
LOG_DIR="/var/log"
BACKUP_DIR="/var/log/log_backup"

if ! command -v gzip &> /dev/null; then
    echo "gzip not found! Installing..."
    if command -v apt &>/dev/null; then
        sudo apt install gzip -y
    elif command -v yum &>/dev/null; then
    	sudo yum install -y gzip
    else 
    	echo "unknown package manager"
    	exit 1
    fi
else
    echo "gzip already installed"
fi

if [ ! -d "$BACKUP_DIR" ]; then
    echo "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
fi

echo "Compressing logs older than 7 days..."
find "$LOG_DIR" -name "*.log" -mtime +7 -exec gzip {} \;

echo "Moving compressed logs to backup directory..."
find "$LOG_DIR" -type f -name "*.gz" -exec mv {} "$BACKUP_DIR" \;

echo "Log cleanup completed successfully!"

# for making it automated every Sunday at 2 AM , write the following in terminal
# crontab -l | { cat; echo "0 2 * * 0 ~/compress_old_logs.sh"; } | crontab -
