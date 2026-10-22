#!/bin/bash
set -e

if [ $# -lt 2 ]; then
  echo "Usage: $0 <source-dir> <backup-destination>"
  exit 1
fi

SOURCE="$1"
DEST="$2"

if [ ! -d "$SOURCE" ]; then
  echo "Error: source directory $SOURCE does not exist"
  exit 1
fi

mkdir -p "$DEST"

TIMESTAMP=$(date +%Y-%m-%d)
ARCHIVE="$DEST/backup-$TIMESTAMP.tar.gz"

tar -czf "$ARCHIVE" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"

if [ -f "$ARCHIVE" ]; then
  echo "Backup created: $ARCHIVE"
  echo "Size: $(du -h "$ARCHIVE" | cut -f1)"
else
  echo "Error: backup archive was not created"
  exit 1
fi

find "$DEST" -name "backup-*.tar.gz" -mtime +14 -delete
echo "Old backups (>14 days) removed."
