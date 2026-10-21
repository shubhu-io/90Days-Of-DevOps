#!/bin/bash
set -euo pipefail

print_header() {
  echo "=========================================="
  echo "  $1"
  echo "=========================================="
}

show_host_os() {
  print_header "Hostname & OS Info"
  hostname
  uname -a
  if [ -f /etc/os-release ]; then
    grep -E '^(PRETTY_NAME|VERSION_ID)=' /etc/os-release
  fi
}

show_uptime() {
  print_header "Uptime"
  uptime
}

show_disk_usage() {
  print_header "Disk Usage (top 5 by size)"
  du -sh /* 2>/dev/null | sort -rh | head -5
}

show_memory() {
  print_header "Memory Usage"
  free -h
}

show_top_cpu() {
  print_header "Top 5 CPU-Consuming Processes"
  ps aux --sort=-%cpu | head -6
}

main() {
  show_host_os
  echo ""
  show_uptime
  echo ""
  show_disk_usage
  echo ""
  show_memory
  echo ""
  show_top_cpu
}

main
