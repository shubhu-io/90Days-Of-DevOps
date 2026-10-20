#!/bin/bash
set -e

mkdir /tmp/devops-test || echo "Directory already exists"
cd /tmp/devops-test || echo "Failed to cd into /tmp/devops-test"
echo "Hello from safe_script" > file.txt || echo "Failed to create file"
echo "Done. Contents:"
cat file.txt
