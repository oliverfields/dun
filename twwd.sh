#!/bin/bash

_twwd_edit_lines() {
  # $1 argument is a command that when evaluated must produce output in format <filename>:<line number>:<line text>

  # https://misc.flogisoft.com/bash/tip_colors_and_formatting
  # Oneliner to list colors:
  # for x in {0..8}; do for i in {30..37}; do for a in {40..47}; do echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "; done; echo; done; done; echo ""

  terminal_width=$(tput cols)
  tabs 5 # set tabs width
  let line_column=$terminal_width-16
  ESC=$(printf '\033')
  title="$1"
  cmd="$2"

  while true; do
    readarray lines < <(eval $cmd)

    if [ ${#lines[@]} -eq 0 ]; then
      echo "No tasks found:("
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
      printf "\tfile://%s\n" "$filename"

    done | perl -lpe "s/(.{$line_column,}?)\s/\$1\n\t/g" \
         | sed "s/#[^\ ]*/${ESC}[1;37;44m&${ESC}[0m/g ; s/TODO/${ESC}[1;37;46m&${ESC}[0m/g ; s/WAIT/${ESC}[1;37;43m&${ESC}[0m/g; s/WONT/${ESC}[1;36;47m&${ESC}[0m/g ; s/DONE/${ESC}[1;37;42m&${ESC}[0m/g ; s/^[0-9]*/${ESC}[0;35m&${ESC}[0m/ ; s#file://\(.*\)#${ESC}[32m\1${ESC}[0m#"

    let y=${#lines[@]}-1
    printf "\nType \e[0;35m0-%s\e[0m to select, anything else exits\n" "$y"
    read selection < /dev/tty

    if [ "$selection" -le $i ] 2>/dev/null ; then
      IFS=':' read -ra selected_file <<< ${lines[$selection]}
      vim +${selected_file[1]} "${selected_file[0]}" --not-a-term
    else
      return 0
    fi
  done
}


twwd() {

  if [[ ! -v TWWD_DIR ]]; then
    echo 'TWWD_DIR environment variable not set, quitting'
    return 1
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

       #TODO add timestampt to text
      _twwd_edit_lines "Recently modified" "ls -1t | head -$max_count | sed 's/\$/:0/'"

      ;;
    list)
      # List tasks filtered by +<word> -<word>
      # Use tab completion for specifying either +#tags or -#tags and for +/-STATUSes 

      cd "$TWWD_DIR"

      if [ $# -eq 1 ]; then
        awk_filter=' && /TODO/' # The ' && ' is to match with the else result
        filters=' +TODO'
      else
        shift

        awk_filter=''
        filters=''

        ## Create awk command to 
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

      _twwd_edit_lines "Tasks, filters:$filters" "awk '$awk_filter {print FILENAME \":\" FNR \":\" \$0}' *"
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

