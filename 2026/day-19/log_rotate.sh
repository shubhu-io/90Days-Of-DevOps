#!/bin/bash
set -e

if [ $# -lt 1 ]; then
  echo "Usage: $0 <log-directory>"
  exit 1
fi

LOG_DIR="$1"

if [ ! -d "$LOG_DIR" ]; then
  echo "Error: $LOG_DIR is not a directory"
  exit 1
fi

compressed=0
deleted=0

while IFS= read -r -d '' file; do
  gzip "$file"
  compressed=$((compressed + 1))
done < <(find "$LOG_DIR" -name "*.log" -mtime +7 -print0)

while IFS= read -r -d '' file; do
  rm -f "$file"
  deleted=$((deleted + 1))
done < <(find "$LOG_DIR" -name "*.gz" -mtime +30 -print0)

echo "Compressed: $compressed file(s)"
echo "Deleted: $deleted file(s)"
