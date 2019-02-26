#!/usr/bin/env bash


show_help(){
  echo "Usage: ${0##*/} [OPTION]... [FILE]..."
  echo "Concatenate FILE(s) to standard output."
  echo
  echo "With no FILE read standard input."
  echo
  echo -e "\t -s \t suppress repeated empty output lines"
  echo -e "\t -E \t display \$ at end of each line"
  echo -e "\t -n \t number all output lines"
  echo -e "\t -h \t display this help and exit"
}

print_text(){

  line="$1"
  CRLF="$2"

  # -E flag
  if [ $show_ends -eq 1 ] && [ $CRLF -eq 1 ]; then
    line="${line}\$"
  fi

  # -n flag
  if [ $show_numbers -eq 1 ]; then
    if [ $CRLF -eq 1 ]; then
      printf "%6s\t%s\n" "$num_line" "$line"
      num_line=$((num_line + 1))
    else
      printf "%6s\t%s" "$num_line" "$line"
      num_line=$((num_line + 1))
    fi
  else
    if [ $CRLF -eq 1 ]; then
      printf "%s\n" "$line"
    else
      printf "%s" "$line"
    fi
  fi
}


# Initializing variables
input_file=
input_array=()
msg_array=()
suppress=0
show_ends=0
show_numbers=0
exit_code=0
OPTIND=1

while getopts sEnh opt; do
  case $opt in
    s)
      suppress=1
      ;;
    E)
      show_ends=1
      ;;
    n)
      show_numbers=1
      ;;
    h)
      show_help >&2
      exit 0
      ;;
    *)
      exit 1
      ;;
  esac
done

# Discard the options and sentinel --
shift "$((OPTIND-1))"

if [ $# = 0 ]; then
  unset input_file
  input_array+=('')
else
  for file in "$@"
  do
    if [ ! -r "$file" ]; then
      #echo "${0##*/}: '$file': file not found or not readable"
      msg_array+=("${0##*/}: $file: No such file or directory")
      exit_code=1
    else
      input_array+=($file)
    fi
  done
fi


blank=0
num_line=1

# iterate over the input files or STDIN
for input_file in "${input_array[@]}"; do
  while IFS= read -r line
  do
    # if line is blank, increment $blank until a line differ than blank
    echo "$line" | grep -q '^[[:space:]]*$' && blank=$((blank + 1)) || blank=0

    if [ $suppress -eq 1 ] && [ $blank -le 1 ]; then

      print_text "$line" "1"

    elif [ $suppress -eq 0 ]; then

      print_text "$line" "1"

    fi
  done <"${input_file:-/dev/stdin}"


  # print the last line if it does not end with CRLF
  blank=0
  if [ "$line" != "" ]; then
    if [ $suppress -eq 1 ] && [ $blank -le 1 ]; then

      print_text "$line" "0"

    elif [ $suppress -eq 0 ]; then

      print_text "$line" "0"

    fi
  fi
done

# error messages, if any
for msg in "${msg_array[@]}"; do
  echo $msg
done
exit $exit_code
