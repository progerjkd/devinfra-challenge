#!/usr/bin/env bash



show_help(){
  echo "Usage: ${0##*/} [-sEn] [FILE]"
  echo "Read FILE and write its contents to STDOUT. With no FILE or"
  echo "when FILE is -, read from STDIN."
  echo
  echo -e "\t -s \t suppress repeated empty output lines"
  echo -e "\t -E \t display \$ at end of each line"
  echo -e "\t -n \t number all output lines"
  echo -e "\t -h \t display this help and exit"
  echo -e "\t -v \t verbose mode"
  exit 1
}

print_text(){

  # -E flag
  if [ $show_ends -eq 1 ]; then
    line="${line}\$"
  fi

  # -n flag
  if [ $show_numbers -eq 1 ]; then
    printf "%6s\t%s\n" "$num_line" "$line"
    num_line=$((num_line + 1))
  else
    printf "%s\n" "$line"
  fi
}

# Initializing variables
input_file=""
verbose=0

suppress=0
show_ends=0
show_numbers=0

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
    v)
      verbose=$((verbose + 1))
      ;;
    h)
      show_help >&2
      ;;
  esac
done

shift "$((OPTIND-1))"   # Discard the options and sentinel --

if [ $# = 1 ]; then
  input_file="$1"
  if [ ! -r $input_file ]; then
    echo "Error: file $input_file not found or is not readable"
    exit 1
  fi
else
  show_help >&2
fi

blank=0
num_line=1

while IFS= read -r line
do
  # if line is blank, increment $blank until a line differ than blank
  echo "$line" | grep '^[[:space:]]*$' >/dev/null && blank=$(echo $blank + 1| bc) || blank=0

  if [ $suppress -eq 1 ] && [ $blank -le 1 ]; then

    print_text

  elif [ $suppress -eq 0 ]; then

    print_text

  fi
done <"$input_file"

# se tiver conteúdo
echo "DEBUG: $line"
if [ "$line" != "" ]; then
  echo "dentro"
  if [ $suppress -eq 1 ] && [ $blank -le 1 ]; then
echo 1
    print_text
echo 2
  elif [ $suppress -eq 0 ]; then
echo 3
    print_text
echo 4
  fi
fi
#echo "$line"
#echo "$num_line $line"
