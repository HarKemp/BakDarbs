#!/bin/bash
# Script to back up PostgreSQL database
DB_NAME="testdb" # Use the actual DB name created on Linux agent
DB_USER="postgres" # Run as postgres user for simplicity
BACKUP_DIR="/var/backup/"
TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
BACKUP_FILENAME="postgres_backup_${DB_NAME}_${TIMESTAMP}.sql.gz"
BACKUP_FILE="${BACKUP_DIR}${BACKUP_FILENAME}"
LOG_FILE="/var/log/automation_logs/db_backup.log"

mkdir -p "$BACKUP_DIR"
mkdir -p "$(dirname "$LOG_FILE")"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting PostgreSQL backup for '$DB_NAME' to '$BACKUP_FILE'" >> "$LOG_FILE"

# Perform dump as postgres user, pipe to gzip
sudo -u "$DB_USER" pg_dump --clean -O "$DB_NAME" | gzip > "$BACKUP_FILE"

if [ ${PIPESTATUS[0]} -eq 0 ] && [ ${PIPESTATUS[1]} -eq 0 ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Database backup successful: $BACKUP_FILE" >> "$LOG_FILE"
  ls -lh "$BACKUP_FILE" >> "$LOG_FILE"
else
  echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: Database backup failed! pg_dump exit: ${PIPESTATUS[0]}, gzip exit: ${PIPESTATUS[1]}" >> "$LOG_FILE"
  exit 1
fi
echo "$(date '+%Y-%m-%d %H:%M:%S') - Database backup script finished." >> "$LOG_FILE"
exit 0
