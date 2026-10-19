#!/bin/bash
SERVICE="nginx"
read -p "Do you want to check the status? (y/n) " ANSWER

if [ "$ANSWER" = "y" ]; then
    systemctl status "$SERVICE"
else
    echo "Skipped."
fi
