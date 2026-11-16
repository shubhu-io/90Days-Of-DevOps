#!/bin/bash
set -e

echo "=== System Info Check ==="
echo "Hostname: $(hostname)"
echo "Date: $(date)"
echo "Disk usage:"
df -h / | tail -1

if ! grep -q "MemTotal" /proc/meminfo; then
  echo "ERROR: cannot read memory info" >&2
  exit 1
fi

echo "All checks passed"
exit 0
