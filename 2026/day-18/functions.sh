#!/bin/bash
greet() {
  echo "Hello, $1!"
}

add() {
  echo "Sum: $(($1 + $2))"
}

greet "Shubham"
add 5 7
