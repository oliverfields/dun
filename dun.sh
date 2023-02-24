#!/bin/bash

# Freeform task tracking for plain text notes

dun() {

  # Directory for dun, defaults to ~/dun or can be specified by DUN_DIR environment variable
  if [[ ! -v DUN_DIR ]]; then
    DUN_DIR="~/dun"
  fi

  # Offer to create DUN_DIR if it does not exist
  if [ -d "$DUN_DIR" ]; then
    cd "$DUN_DIR"
  else
    echo "$DUN_DIR does not exist (set environment variable DUN_DIR to specify another location). Create it? [y|n]"
    read selection
    if [ "$selection" = "y" ]; then
      mkdir -p "$DUN_DIR"
    fi 
  fi

  # Jump to DUN_DIR if no arguments passed
  if [ $# -eq 0 ]; then
    command cd "$DUN_DIR"
    return
  fi

  case $1 in
    help)
    
      echo -e '
Task tracking from freeform notes. Tasks are single lines containing a status and optionally one or more tags. Notes are plain text files.

\e[1mdun\e[0m [new|list|recent|help]\e[0m

    \e[1mlist\e[0m [[+|-]<FILTER STRING>..]
        List tasks and filter them, if no filter specified filter by TODO. Filter strings are prefixed by either + or -, + will match if the string is present, whilst - means the string must be absent.

        \e[1mExample:\e[0m
            dun list +#ProjectA -DONE
                List tasks that are not DONE and are tagged #ProjectA

    \e[1mnew\e[0m [NAME STRING]
        Create new note text file in DUN_DIR. If Name is specified the file name will be  yyyy-mm-dd-[name]-[increment], else just yyyy-mm-dd-[increment].

        \e[1mExample:\e[0m
            dun new retrospective
                File name will be yyyy-mm-dd-retrospective-0 (if the file already exists the -0 will increment until the file name is unique)

    \e[1mrecent\e[0m [NUMBER]
        List the first Number of recently modified note files. Number defaults to 9.

    \e[1mhelp\e[0m
        This text.
' | fmt
      ;;
    new)
      # Create new file in DUN_DIR
      num=0

      if [ $# -eq 2 ]; then
        note_name=-$2
      else
        note_name=''
      fi

      new_file="$DUN_DIR/$(date +%Y%m%d)$note_name"

      while [ -e "${new_file}-$num" ]; do
        num=$((num +1))
      done

      new_file="${new_file}-$num"

      vim -c 'set syntax=dun' "$new_file"

      ;;
    recent)
      #Select to open one of X recently modified files from DUN_DIR

      if [ "$2" != "" ]; then
        max_count=$2
      else
        max_count=10
      fi

      # find just files in DUN_DIR and get their epoch and date stamp, sort (because epoch is first)
      # returning $max_count most recent. Use awk and sed to mangle lines so they confirm to expected input
      _dun_edit_lines "Recently modified" "LC_ALL=en_US.UTF-8 find '$DUN_DIR' -maxdepth 1 -type f -exec date -r {} +%s:%Y-%m-%d\ %a\ week\ %V:{} \; | sort --reverse | head -$max_count | awk 'BEGIN { FS = \":\" } ; { print \$3 \":0:\" \$2 }' | sed 's#^$DUN_DIR/##'"

      ;;
    list)
      # List tasks filtered by +<word> -<word>

      if [ $# -eq 1 ]; then
        awk_filter=' && /TODO/' # The ' && ' is to match with the else result
        filters=' +TODO'
      else
        shift

        awk_filter=''
        filters=''

        ## Create awk command to filter lines
        while (( $# )); do
          filters="$filters $1"
          case ${1:0:1} in
            +)
              awk_filter="$awk_filter && /${1:1}/"
              ;;
            -)
              awk_filter="$awk_filter && !/${1:1}/"
              ;;
            *)
              echo "Filters must start with either + or -"
              return 1
              ;;
          esac
          shift
        done
      fi
      awk_filter="${awk_filter:4}" # Remove first '&& '

      # Create list of the note files, use instead of * to ensure only files and that quoteing is correct
      note_files="$(find . -maxdepth 1 -type f | sed "s/^\.\//'/ ; s/$/'/" | tr '\n' ' ')"

      _dun_edit_lines "Tasks$filters" "awk '$awk_filter {print FILENAME \":\" FNR \":\" \$0}' $note_files"
      ;;
  esac
}


_dun_edit_lines() {
  # Accepts a title and command that will list tasks (lines in note files) and allows user to select a line and open it in editor repeatedly
  # $1 argument is the command that when evaluated must produce output in format <filename>:<line number>:<line text>

  # To make this pretty there is a lot of font coloring going on
  # https://misc.flogisoft.com/bash/tip_colors_and_formatting
  # Oneliner to list colors:
  # for x in {0..8}; do for i in {30..37}; do for a in {40..47}; do echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "; done; echo; done; done; echo ""
  terminal_width=$(tput cols)
  tabs 5 # set tabs width
  let line_column=$terminal_width-16
  ESC=$(printf '\033')
  title="$1"
  cmd="$2"

  # The loop evaluates the command argument and allows user to select a line to edit
  while true; do
    readarray lines < <(eval $cmd)

    if [ ${#lines[@]} -eq 0 ]; then
      # No tasks found:(
      return 1
    fi

    clear

    printf "\e[1m%s\e[0m\n" "$title"

    for ((i=0;i<${#lines[@]};i++)); do
      IFS=':' read -r -a line <<< "${lines[$i]}"
      filename="${line[0]}"
      line_number="${line[1]}"
      line_text="$(echo "${line[2]}" | sed 's/^ *// ; s/^-// ; s/^ *//')"

      printf "\n%s\t%s\n" "$i" "$line_text"
      printf "\tfile://%s" "$filename"

         # perl makes text into column, and sed colorizes output
    done | perl -lpe "s/(.{$line_column,}?)\s/\$1\n\t/g" \
         | sed "s/#[^\ ]*/${ESC}[1;37;44m&${ESC}[0m/g ; s/TODO/${ESC}[1;37;46m&${ESC}[0m/g ; s/WAIT/${ESC}[1;37;43m&${ESC}[0m/g; s/WONT/${ESC}[1;36;47m&${ESC}[0m/g ; s/DONE/${ESC}[1;37;42m&${ESC}[0m/g ; s/^[0-9]*/${ESC}[0;35m&${ESC}[0m/ ; s#file://\(.*\)#${ESC}[32m\1${ESC}[0m#"

    let y=${#lines[@]}-1
    printf "\nType \e[0;35m0-%s\e[0m to select, anything else exits\n" "$y"
    read selection < /dev/tty

    # Open selected file at given location in vim (for now..)
    if [ "$selection" -le ${#lines[@]} ] 2>/dev/null ; then
      IFS=':' read -ra selected_file <<< ${lines[$selection]}

      # Well, if you would like to use another editor, this is the line to change:)
      vim -c 'set syntax=dun' +${selected_file[1]} "${selected_file[0]}" --not-a-term
    else
      return 0
    fi
  done
}


_dun() {
  # Bash completion
  # Add 'complete -F _dun dun' to .bashrc to enable
  # https://devmanual.gentoo.org/tasks-reference/completion/index.html
  # https://www.gnu.org/software/gnuastro/manual/html_node/Bash-TAB-completion-tutorial.html

  command_name=$1
  current_word=$2
  word_before_current_word=$3
  COMPREPLY=()

  options="new list recent help"

  # tags and statuses start either with a - or +
  statuses=("TODO" "WAIT" "WONT" "DONE")
  readarray tags < <(cd "$DUN_DIR" && grep --directories=skip --no-filename --only-matching '#[[:alnum:]]\{1,\}' * | sort | uniq)
  filters=("${statuses[@]}" "${tags[@]}")
  for ((i=0;i<${#filters[@]};i++)); do
    options="$options +${filters[$i]} -${filters[$i]}"
  done

  COMPREPLY=( $(compgen -W "$options" -- ${current_word}) )
}
