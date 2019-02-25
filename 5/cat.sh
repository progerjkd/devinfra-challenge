#!/usr/bin/env bash

file=b.txt

line_number=''

while IFS= read -r line
do
  echo "${line}"
done <"$file"

# se tiver conteúdo
echo "${line}"
