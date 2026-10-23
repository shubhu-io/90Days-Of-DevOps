#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

usage() { echo "Usage: $0 <log_file>"; }
die() { echo "Error: $*" >&2; exit 1; }

[ "$#" -eq 1 ] || { usage >&2; exit 1; }

LOG_FILE="$1"

[ -f "$LOG_FILE" ] || die "file does not exist: $LOG_FILE"
[ -r "$LOG_FILE" ] || die "file is not readable: $LOG_FILE"

echo "--- Critical Events ---"

CRITICAL_LINES=$(grep -n 'CRITICAL' "$LOG_FILE" | tr -d '\r' || true)

if [ -z "$CRITICAL_LINES" ]; then
    echo "(none)"
else
    printf '%s\n' "$CRITICAL_LINES" | sed 's/^\([0-9]*\):/Line \1: /'
fi
