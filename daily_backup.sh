#!/bin/bash

BACKUP_DIR="/var/backups"
LOG_FILE="/var/log/backup.log"

EMAIL="th1s.1s.just.4.test.m41l@gmail.com"

if ! command -v mailx &> /dev/null; then
    echo "mailx not found! Installing..."
    if command -v apt &>/dev/null; then
	sudo apt install mailutils -y
    elif command -v yum &>/dev/null; then
	sudo yum install mailutils -y
    else 
    	echo "unknown package manager"
    	exit 1
    fi
fi

mkdir -p "$BACKUP_DIR"
cd $BACKUP_DIR

log_message() {
    echo "$(date +%F_%T) - $1" | tee -a "$LOG_FILE"
}

log_message "Starting backup of /home directory..."

if tar -zcvf "home_backup_$(date +%F_%H%M%S)" /home/ >> "$LOG_FILE" 2>&1; then
    log_message "Backup completed successfully"
    echo "Backup successful at $(date +%F_%T)" | mailx -s "Backup status" $EMAIL
else
    log_message "Backup failed!"
    echo "Backup failed at $(date +%F_%T)" | mailx -s "Backup status" $EMAIL
    exit 1
fi

log_message "Rotating backups: Keeping last 7 files..."
find "$BACKUP_DIR" -name "home_backup_*.tar.gz" -mtime +7 -exec rm -f {} \;

# another complex way from stackoverflow -->	ls -tp "$BACKUP_DIR"/home_backup_*.tar.gz | grep -v '/$' | tail -n +8 | xargs -I {} rm -- {}

log_message "Backup process finished successfully."

# for making it automated as a daily at 1 AM , write the following in terminal
# crontab -l | { cat; echo "0 1 * * * /path/to/daily_backup.sh"; } | crontab -
