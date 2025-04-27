#!/bin/bash
# Script to clean up old log files
LOG_DIR_APP="/var/log/automation_logs" # Custom app logs
LOG_DIR_ZABBIX="/var/log/zabbix"       # Zabbix logs
DAYS_TO_KEEP=7
LOG_FILE="/var/log/automation_logs/cleanup.log" 

mkdir -p "$(dirname "$LOG_FILE")"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting cleanup of logs older than ${DAYS_TO_KEEP} days." >> "$LOG_FILE"

echo "--- Cleaning up $LOG_DIR_APP ---" >> "$LOG_FILE"
find "$LOG_DIR_APP" -name '*.log' -type f -mtime +$DAYS_TO_KEEP -print -delete >> "$LOG_FILE" 2>&1

echo "--- Cleaning up $LOG_DIR_ZABBIX ---" >> "$LOG_FILE"
find "$LOG_DIR_ZABBIX" -name '*.log' -type f -mtime +$DAYS_TO_KEEP -print -delete >> "$LOG_FILE" 2>&1
# Optionally add find for system logs like /var/log/syslog.*.gz if needed

echo "$(date '+%Y-%m-%d %H:%M:%S') - Cleanup script finished." >> "$LOG_FILE"
exit 0
