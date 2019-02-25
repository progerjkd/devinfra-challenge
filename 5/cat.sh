#!/usr/bin/env bash

file=b.txt

line_number=''
blank=0
num_line=1
while IFS= read -r line
do
  echo "$line" | grep '^[[:space:]]*$' >/dev/null && blank=$(echo $blank + 1| bc) || blank=0
  if [ $blank -le 1 ]; then
    echo "$num_line $line\$" # 6 casas
    num_line=$(echo $num_line + 1 | bc)
  fi
done <"$file"

# se tiver conteúdo
#echo "$line"
echo "$num_line $line"
