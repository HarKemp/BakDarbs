#!/bin/bash
# Script to check and apply system updates (requires sudo privileges)
LOG_FILE="/var/log/automation_logs/update.log"
mkdir -p "$(dirname "$LOG_FILE")"

echo "======================================================" >> "$LOG_FILE"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting system update check..." >> "$LOG_FILE"
echo "======================================================" >> "$LOG_FILE"

apt update >> "$LOG_FILE" 2>&1
if [ $? -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: apt update failed." >> "$LOG_FILE"; exit 1
fi
echo "$(date '+%Y-%m-%d %H:%M:%S') - apt update completed." >> "$LOG_FILE"

DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --allow-downgrades --allow-remove-essential --allow-change-held-packages >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then echo "$(date '+%Y-%m-%d %H:%M:%S') - System upgrade completed successfully." >> "$LOG_FILE"; else echo "$(date '+%Y-%m-%d %H:%M:%S') - WARNING: System upgrade command finished with non-zero status." >> "$LOG_FILE"; fi

echo "======================================================" >> "$LOG_FILE"; echo "$(date '+%Y-%m-%d %H:%M:%S') - Update script finished." >> "$LOG_FILE"; echo "======================================================" >> "$LOG_FILE"
exit 0
