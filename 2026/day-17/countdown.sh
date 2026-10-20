#!/bin/bash
read -p "Enter a number to count down from: " num
while [ "$num" -gt 0 ]; do
  echo "$num"
  num=$((num - 1))
done
echo "Done!"
