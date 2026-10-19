#!/bin/bash
read -p "Enter file name: " FILE

if [ -f "$FILE" ]; then
    echo "$FILE exists."
else
    echo "$FILE does not exist."
fi
