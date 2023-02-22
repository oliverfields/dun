#!/bin/bash

_twwd_select_print_task() {
  task_number=$1
  task_line=$2
  max_pad_length=$3

  # https://misc.flogisoft.com/bash/tip_colors_and_formatting
  # Oneliner to list colors:
  # for x in {0..8}; do for i in {30..37}; do for a in {40..47}; do echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "; done; echo; done; done; echo ""
  ESC=$(printf '\033')

  tl_file=$(echo $task_line | cut -d ':' -f1)
  tl_text=$(echo $task_line | cut -d ':' -f3-)

  padding=""
  for (( x=${#task_number};x<${#max_pad_length}; x++ )) ; do
    padding=" $padding"
  done

  IFS=':' read -ra tl <<<"$task_line"

  printf "\e[0;35m%s\e[0m%s " "$task_number" "$padding" 
  printf "%s " "${tl_text}" | sed "s/^ *// ; s/^- *// ; s/\n// ; s/#[^\ ]*/${ESC}[1;37;44m&${ESC}[0m/g ; s/TODO/${ESC}[1;37;46m&${ESC}[0m/g ; s/WAIT/${ESC}[1;37;43m&${ESC}[0m/g; s/WONT/${ESC}[1;36;47m&${ESC}[0m/g ; s/DONE/${ESC}[1;37;42m&${ESC}[0m/g"
  printf "\e[32m%s\e[0m\n" "$tl_file"

  printf "\e[0;35m%s\e[0m%s " "$task_number" "$padding" 
  printf "%s " "${tl_text}" | sed "s/^ *// ; s/^- *// ; s/\n// ; s/#[^\ ]*/${ESC}[1;37;44m&${ESC}[0m/g ; s/TODO/${ESC}[1;37;46m&${ESC}[0m/g ; s/WAIT/${ESC}[1;37;43m&${ESC}[0m/g; s/WONT/${ESC}[1;36;47m&${ESC}[0m/g ; s/DONE/${ESC}[1;37;42m&${ESC}[0m/g"
  printf "\e[32m%s\e[0m\n" "$tl_file"
}


_twwd_edit_lines() {
  # $1 argument is a command that when evaluated must produce output in format <filename>:<line number>:<line text>

  #column -s '§' -t
  #echo $sum_options options
  while true; do
    readarray lines < <(eval $1)
    for ((i=0;i<${#lines[@]};i++)); do
      IFS=':' read -r -a line <<< "${lines[$i]}"
      filename="${line[0]}"
      line_number="${line[1]}"
      line_text="$(echo "${line[2]}" | sed 's/^ *// ; s/^-// ; s/^ *//')"

      printf "%s§%s\n" "$i" "$line_text"
      printf "§%s\n" "$filename"
    done | column --separator '§' --table --table-noheadings --table-columns C1,C2 --table-wrap C2

    if [ $i -eq 0 ]; then
      echo "No tasks found:("
      break
    fi

    echo ""
    printf "Type \e[0;35m0-%s\e[0m to select, anything else exits\n" "$i"
    read selection < /dev/tty

    if [ "$selection" -le $i ] 2>/dev/null ; then
      IFS=':' read -ra selected_file <<< ${lines[$selection]}
      vim +${selected_file[1]} "${selected_file[0]}" --not-a-term
    else
      break
    fi
  done
}


twwd() {

  if [[ ! -v TWWD_DIR ]]; then
    echo 'TWWD_DIR environment variable not set, quitting'
    return
  fi

  if [ $# -eq 0 ]; then
    command cd "$TWWD_DIR"
    return
  fi

  case $1 in
    help)
      echo "twwd [new|list|last|help]"
      ;;
    new)
      num=0

      if [ $# -eq 2 ]; then
        note_name=-$2
      else
        note_name=''
      fi

      new_file="$TWWD_DIR/$(date +%Y%m%d)$note_name"

      while [ -e "${new_file}-$num" ]; do
        num=$((num +1))
      done

      new_file="${new_file}-$num"

      vim "$new_file"

      ;;
    last)
      #Select to open one of X last edited files
      cd "$TWWD_DIR"

      if [ "$2" != "" ]; then
        max_count=$2
      else
        max_count=9
      fi

      _twwd_edit_lines "ls -1t | head -$max_count | sed 's/\$/:0/'"

      ;;
    list)
      # List tasks filtered by +<word> -<word>
      # Use tab completion for specifying either +#tags or -#tags and for +/-STATUSes 

      cd "$TWWD_DIR"

      if [ $# -eq 1 ]; then
        awk_filter=' && /TODO/' # The ' && ' is to match with the else result
      else
        shift

        awk_filter=''

        ## Create awk command to 
        while (( $# )); do
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

      _twwd_edit_lines "awk '$awk_filter {print FILENAME \":\" FNR \":\" \$0}' *"
      ;;
    tags)
      # Select files containing tags and matching a status
      cd "$TWWD_DIR"

      if [ "$2" != "" ] ; then
        filter_by_status_regexp="$2"
      else
        filter_by_status_regexp="TODO"
      fi

      while true ; do
      # Find all tags that have a given status, tags are #textnotcontainingspace
        readarray tags_with_status < <(grep --exclude-dir=assets "$filter_by_status_regexp" * | grep --only-matching '#[a-zA-Z0-9]\{1,\}' | sort | uniq)

        for (( i=0; i<${#tags_with_status[@]}; i++)) ; do
          echo -en "\e[0;35m${i} \e[0;34m ${tags_with_status[$i]}\e[0m"
        done
        let y=$i-1
        [ $y -lt 0 ] && break
        echo ""
        printf "Type \e[0;35m0-%s\e[0m to select, anything else exits\n" "$y"
        read tag_selection

        selected_tag="${tags_with_status[$tag_selection]}"
        selected_tag="${selected_tag/$'\n'}" # Strip newline

        if [ "$tag_selection" -lt $i ] 2>/dev/null ; then

          while true ; do
            # Find any lines that contain either status.*tag or tag.*status


            readarray tasks < <(grep -E --line-number --with-filename --exclude-dir=assets "${filter_by_status_regexp}.*${selected_tag}|${selected_tag}.*${filter_by_status_regexp}" *)

            echo -e "\n\e[1mFiltering by status \e[0;36m$filter_by_status_regexp\e[1m and tag \e[0;34m$selected_tag\e[0m\n"

            for (( i=0; i<${#tasks[@]}; i++)) ; do
              _twwd_select_print_task "${i}" "${tasks[$i]}" "${#tasks[@]}"
            done
            let y=$i-1

            [ $y -lt 0 ] && echo -e "\e[1;31mTag $selected_tag no longer exists, listing tags:\e[0m\n" && break
            echo ""
            printf "Type \e[0;35m0-%s\e[0m to select, anything else exits\n" "$y"
            read task_selection

            if [ "$task_selection" -lt $i ] 2>/dev/null ; then
              IFS=':' read -ra selected_file <<< ${tasks[$task_selection]}
              vim +${selected_file[1]} "${selected_file[0]}"
            else
              break
            fi
          done
        else
          break
        fi
      done
      ;;
  esac
}

