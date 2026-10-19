#!/bin/bash
read -p "Enter a number: " NUM

if [ "$NUM" -gt 0 ]; then
    echo "$NUM is positive."
elif [ "$NUM" -lt 0 ]; then
    echo "$NUM is negative."
else
    echo "$NUM is zero."
fi
