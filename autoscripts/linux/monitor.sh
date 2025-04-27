#!/bin/bash
# Script to monitor system resources
LOG_FILE="/var/log/system_health.log" 
mkdir -p "$(dirname "$LOG_FILE")"

echo "----------------------------------------" >> "$LOG_FILE"
echo "System Health Check: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"
echo ">>> CPU Load & Top Processes:" >> "$LOG_FILE"; top -bn1 | head -n 15 >> "$LOG_FILE"; echo "" >> "$LOG_FILE"
echo ">>> Disk Usage (Human Readable):" >> "$LOG_FILE"; df -h >> "$LOG_FILE"; echo "" >> "$LOG_FILE"
echo ">>> Memory Usage (Megabytes):" >> "$LOG_FILE"; free -m >> "$LOG_FILE"; echo "" >> "$LOG_FILE"
echo "--- Check Complete ---" >> "$LOG_FILE"
exit 0
