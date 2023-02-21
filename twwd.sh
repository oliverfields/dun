#!/bin/bash


_twwd_select_print_task() {
  task_number=$1
  task_line=$2
  max_pad_length=$3

  # https://misc.flogisoft.com/bash/tip_colors_and_formatting
  # Oneliner to list colors:
  # for x in {0..8}; do for i in {30..37}; do for a in {40..47}; do echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "; done; echo; done; done; echo ""
  #FONT_DEFAULT="\033[0m"
  #FONT_SELECT_NUMBER="\033[0;35m"
  #FONT_FILENAME="\033[36m"
  ESC=$(printf '\033')

  tl_file=$(echo $task_line | cut -d ':' -f1)
  tl_text=$(echo $task_line | cut -d ':' -f3-)

  padding=""
  for (( x=${#task_number};x<${#max_pad_length}; x++ )) ; do
    padding=" $padding"
  done

  IFS=':' read -ra tl <<<"$task_line"

  printf "\e[0;35m%s\e[0m%s" "$task_number" "$padding" 
  printf " %s " "${tl_text}" | sed "s/\n// ; s/#[^\ ]*/${ESC}[0;34m&${ESC}[0m/g ; s/[A-Z0-9\-_]\{4,\}/${ESC}[36m&${ESC}[0m/g"
  printf "\e[32m%s\e[0m\n" "$tl_file"
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
      echo "j [new|tasks|last|tags]"
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
    tasks)
      cd "$TWWD_DIR"

      # If just called j tasks, then find all containing TODOs
      if [ $# -eq 1 ]; then
        regexp='TODO'
      # If called j tasks <regexp>, then search for that
      elif [ "$2" = "all" ]; then
        # Default regexp finds all lines containing at least 4 consecutive uppercase letter
        regexp='[A-Z0-9\-_]\{4,\}'
      else
        regexp="$2"
      fi

      while true ; do
        readarray tasks < <(grep --line-number --with-filename --exclude-dir=assets "$regexp" *)
        for (( i=0; i<${#tasks[@]}; i++)) ; do
          _twwd_select_print_task "${i}" "${tasks[$i]}" "${#tasks[@]}"
        done
        let y=$i-1
        [ $y -lt 0 ] && break
        echo ""
        printf "Type \e[0;35m0-%s\e[0m to select, anything else exits\n" "$y"
        read selection

        if [ "$selection" -lt $i ] 2>/dev/null ; then
          IFS=':' read -ra selected_file <<< ${tasks[$selection]}
          vim +${selected_file[1]} "${selected_file[0]}"
        else
          break
        fi
      done

      ;;
    last)
      #Select to open one of X last edited files
      cd "$TWWD_DIR"

      if [ "$2" != "" ]; then
        max_count=$2
      else
        max_count=9
      fi

      while true ; do
        readarray tasks < <(ls -1t | head -$max_count | sed 's/$/:0/')
        for (( i=0; i<${#tasks[@]}; i++)) ; do
          _twwd_select_print_task "${i}" "${tasks[$i]}"
        done
        let y=$i-1
        [ $y -lt 0 ] && break
        echo ""
        printf "Type \e[0;35m0-%s\e[0m to select, anything else exits\n" "$y"
        read selection

        if [ "$selection" -lt $i ] 2>/dev/null ; then
          IFS=':' read -ra selected_file <<< ${tasks[$selection]}
          vim +${selected_file[1]} "${selected_file[0]}"
        else
          break
        fi
      done
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
    *)
      cd "$TWWD_DIR"
      eval $*
      ;;
  esac
}


