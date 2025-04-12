#!/bin/bash

LOG_FILE="/var/log/system_update.log"

log_message() {
    echo "$(date +%F_%T) - $1" | tee -a "$LOG_FILE"
}

log_message "Starting system update..."

if (sudo apt update || sudo yum update) >> "$LOG_FILE" 2>&1; then
    log_message "Package lists updated successfully."
else
    log_message "Failed to update package lists."
    exit 1
fi

if (sudo apt upgrade -y || sudo yum upgrade -y) >> "$LOG_FILE" 2>&1; then
    log_message "System upgrade completed."
else
    log_message "System upgrade failed."
    exit 1
fi

log_message "System update finished successfully."

# for making it automated as a daily task at midnight , write the following in terminal
# crontab -l | { cat; echo "0 0 * * * ~/system_update.sh"; } | crontab -
