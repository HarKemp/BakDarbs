#!/bin/bash
set -o pipefail # Make pipeline exit status be the rightmost non-zero status, or zero if all succeed
set -e          # Exit immediately if a command exits with a non-zero status (optional but good)

# --- Configuration ---
DB_NAME="testdb" # Use the actual DB name created on Linux agent
DB_USER="postgres" # Usually run dump as postgres user
BACKUP_DIR="/var/backup/"
TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
BACKUP_FILENAME="postgres_backup_${DB_NAME}_${TIMESTAMP}.sql.gz"
BACKUP_FILE="${BACKUP_DIR}${BACKUP_FILENAME}"
LOG_FILE="/var/log/automation_logs/db_backup.log"
# --- End Configuration ---

# Ensure directories exist
# Need sudo if autouser doesn't own /var/backup parent or /var/log/automation_logs parent
# Assuming setup script handled permissions correctly on the final dirs
mkdir -p "$BACKUP_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting PostgreSQL backup for database '$DB_NAME' to '$BACKUP_FILE'" >> "$LOG_FILE"

# Perform the dump and compress
# The redirection '>' is done by the shell running this script (likely 'haralds')
sudo -u "$DB_USER" pg_dump --clean -O "$DB_NAME" | gzip > "$BACKUP_FILE"
# Capture the exit status of the *entire pipeline* immediately
EXIT_STATUS=$? 

# Check the overall pipeline exit status
if [ $EXIT_STATUS -eq 0 ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Database backup successful: $BACKUP_FILE" >> "$LOG_FILE"
  ls -lh "$BACKUP_FILE" >> "$LOG_FILE" # Log file size
else
  echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: Database backup pipeline failed with exit status $EXIT_STATUS!" >> "$LOG_FILE"
  # Consider removing partial backup file on failure
  rm -f "$BACKUP_FILE"
  exit 1 # Ensure script exits non-zero
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Database backup script finished." >> "$LOG_FILE"
exit 0
