#!/bin/ksh
for file in label/*.lab; do
  sed -i '1i !ENTER' "$file" &&
  printf '\n!EXIT' >> "$file"
done
