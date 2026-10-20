#!/bin/bash
if [ $# -eq 0 ]; then
  echo "Usage: ./greet.sh <name>"
  exit 1
else
  echo "Hello, $1!"
fi