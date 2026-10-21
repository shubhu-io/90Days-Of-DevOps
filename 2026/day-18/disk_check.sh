#!/bin/bash
check_disk() {
  echo "=== Disk Usage (/) ==="
  df -h /
}

check_memory() {
  echo "=== Free Memory ==="
  free -h
}

check_disk
echo ""
check_memory
