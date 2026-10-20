#!/bin/bash
if [ "$EUID" -ne 0 ]; then
  echo "Error: run this script as root (sudo)."
  exit 1
fi

packages=("nginx" "curl" "wget")

for pkg in "${packages[@]}"; do
  if dpkg -s "$pkg" &> /dev/null; then
    echo "$pkg: already installed, skipping."
  else
    echo "$pkg: not found, installing..."
    apt-get install -y "$pkg"
    echo "$pkg: installed."
  fi
done
