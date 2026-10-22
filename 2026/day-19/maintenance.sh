#!/bin/bash
set -e

LOG_DIR="/var/log/myapp"
SOURCE="/var/www/html"
BACKUP_DEST="/backups"
MAINT_LOG="/var/log/maintenance.log"

timestamp() {
  date '+%Y-%m-%d %H:%M:%S'
}

echo "$(timestamp) - Starting maintenance" >> "$MAINT_LOG"

echo "$(timestamp) - Running log rotation" >> "$MAINT_LOG"
./log_rotate.sh "$LOG_DIR" >> "$MAINT_LOG" 2>&1 || echo "$(timestamp) - Log rotation failed" >> "$MAINT_LOG"

echo "$(timestamp) - Running backup" >> "$MAINT_LOG"
./backup.sh "$SOURCE" "$BACKUP_DEST" >> "$MAINT_LOG" 2>&1 || echo "$(timestamp) - Backup failed" >> "$MAINT_LOG"

echo "$(timestamp) - Maintenance finished" >> "$MAINT_LOG"
