#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

usage() { echo "Usage: $0 <log_file>"; }
die() { echo "Error: $*" >&2; exit 1; }

[ "$#" -eq 1 ] || { usage >&2; exit 1; }

LOG_FILE="$1"

[ -f "$LOG_FILE" ] || die "file does not exist: $LOG_FILE"
[ -r "$LOG_FILE" ] || die "file is not readable: $LOG_FILE"

echo "Log file found: $LOG_FILE"
