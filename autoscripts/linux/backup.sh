#!/bin/bash
# Script to back up web server directory contents
SOURCE_DIR="/var/www" 
DEST_DIR="/var/backup/"
TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
ARCHIVE_NAME="web_backup_${TIMESTAMP}.tar.gz"
DEST_FILE="${DEST_DIR}${ARCHIVE_NAME}"
LOG_FILE="/var/log/automation_logs/backup.log" # Log to custom dir

mkdir -p "$DEST_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting backup of ${SOURCE_DIR} contents to ${DEST_FILE}" >> "$LOG_FILE"
# Use -C to change directory so archive contains files/dirs directly from /var/www
tar czf "${DEST_FILE}" -C "${SOURCE_DIR}" . >> "$LOG_FILE" 2>&1 

if [ $? -eq 0 ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Backup successful: ${DEST_FILE}" >> "$LOG_FILE"
  ls -lh "$DEST_FILE" >> "$LOG_FILE" 
else
  echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: Backup failed!" >> "$LOG_FILE"
  exit 1
fi
echo "$(date '+%Y-%m-%d %H:%M:%S') - Backup script finished." >> "$LOG_FILE"
exit 0
