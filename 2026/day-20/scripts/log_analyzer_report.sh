#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

usage() { echo "Usage: $0 <log_file> [--archive]"; }
die() { echo "Error: $*" >&2; exit 1; }

ARCHIVE=0
args=()
for arg in "$@"; do
    case "$arg" in
        --archive) ARCHIVE=1 ;;
        -h|--help) usage; exit 0 ;;
        -*) die "unknown option: $arg" ;;
        *) args+=("$arg") ;;
    esac
done

[ "${#args[@]}" -eq 1 ] || { usage >&2; exit 1; }

LOG_FILE="${args[0]}"

[ -f "$LOG_FILE" ] || die "file does not exist: $LOG_FILE"
[ -r "$LOG_FILE" ] || die "file is not readable: $LOG_FILE"

DATE=$(date +%Y-%m-%d)
REPORT="log_report_${DATE}.txt"
TOTAL_LINES=$(awk 'END { print NR }' "$LOG_FILE")
ERROR_COUNT=$(grep -Ec 'ERROR|Failed' "$LOG_FILE" || true)
CRITICAL_LINES=$(grep -n 'CRITICAL' "$LOG_FILE" | tr -d '\r' || true)
TOP_ERRORS=$(grep 'ERROR' "$LOG_FILE" \
    | tr -d '\r' \
    | sed -E 's/^[0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]+[0-9:]+[[:space:]]+\[[^]]+\][[:space:]]*//; s/[[:space:]]+-[[:space:]]+[0-9]+$//' \
    | sort | uniq -c | sort -rn | head -5 || true)

{
    echo "========== LOG ANALYSIS REPORT =========="
    echo
    echo "Date of analysis: $DATE"
    echo "Log file name: $(basename "$LOG_FILE")"
    echo "Total lines processed: $TOTAL_LINES"
    echo "Total error count: $ERROR_COUNT"
    echo
    echo "---------- Top 5 Error Messages ----------"
    if [ -z "$TOP_ERRORS" ]; then
        echo "(none)"
    else
        echo "$TOP_ERRORS"
    fi
    echo
    echo "---------- Critical Events ----------"
    if [ -z "$CRITICAL_LINES" ]; then
        echo "(none)"
    else
        printf '%s\n' "$CRITICAL_LINES" | sed 's/^\([0-9]*\):/Line \1: /'
    fi
    echo
} > "$REPORT"

echo "Summary report generated: $REPORT"

if [ "$ARCHIVE" -eq 1 ]; then
    mkdir -p archive
    BASE=$(basename "$LOG_FILE")
    TARGET="archive/$BASE"
    if [ -e "$TARGET" ]; then
        TARGET="archive/${BASE}.$(date +%Y%m%d-%H%M%S)"
    fi
    mv -- "$LOG_FILE" "$TARGET"
    echo "Moved $LOG_FILE to $TARGET"
fi

echo "Log analysis completed."
