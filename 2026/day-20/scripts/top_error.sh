#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

usage() { echo "Usage: $0 <log_file>"; }
die() { echo "Error: $*" >&2; exit 1; }

[ "$#" -eq 1 ] || { usage >&2; exit 1; }

LOG_FILE="$1"

[ -f "$LOG_FILE" ] || die "file does not exist: $LOG_FILE"
[ -r "$LOG_FILE" ] || die "file is not readable: $LOG_FILE"

echo "--- Top 5 Error Messages ---"

TOP_ERRORS=$(grep 'ERROR' "$LOG_FILE" \
    | tr -d '\r' \
    | sed -E 's/^[0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]+[0-9:]+[[:space:]]+\[[^]]+\][[:space:]]*//; s/[[:space:]]+-[[:space:]]+[0-9]+$//' \
    | sort | uniq -c | sort -rn | head -5 || true)

if [ -z "$TOP_ERRORS" ]; then
    echo "(none)"
else
    printf '%s\n' "$TOP_ERRORS"
fi
