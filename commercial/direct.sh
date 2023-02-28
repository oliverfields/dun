#!/bin/bash


function annotate() {
  file=$1
  text=$2
  text_position=$3

  text_file="${file/.gif/-text.gif}"

  # Create text
  convert -font Hack-Regular-Nerd-Font-Complete -pointsize 20 -background '#666666' -border 4 -bordercolor '#666666' -stroke white -fill white pango:"$text" "$text_file"

  # Add text to frame file
  convert "$file" "$text_file" -geometry "$text_position" -composite "$file"
}


if [ -d "frames" ]; then
  rm frames/*
else
  mkdir frames
fi

cd screenshots || exit 1

# Chop off title bar and scroll bar
for i in *.gif; do
  echo $i
  convert $i -gravity East -chop 10x0 ../frames/$i 
  convert ../frames/$i -chop 0x25 ../frames/$i
done

cd ../frames

annotate "01_create-standup-command.gif" "👆️ Create a new note named standup" "+40+40"
annotate "02_create-standup-note.gif" "👆️ Note opens in vi, add a new task\nwith status TODO\n\nTasks are any line containing a valid Status\n\nAdd hashtags anywhere to create tags\n\nNotes are plain text files" "+40+40"
annotate "03_list-tasks-command.gif" "👆️ List open tasks from all notes files" "+40+40"
annotate "04_list-tasks-before-update.gif" "👈️ Cindy task is\ndone. Lets close.." "+500+90"
annotate "05_update-task-call-cindy-1.gif" "Change 👆️ TODO to DONE to close task" "+300+300"
annotate "06_update-task-call-cindy-2.gif" "✅👍️" "+340+330"
annotate "07_note-markup.gif" "Dun should play nice with\nyour preffered markup👌" "+150+100"
annotate "08_list-tasks-after-update.gif" "Return to updated\ntask list💫" "+450+60"
annotate "09_list-projectx-done-tasks-command.gif" "👆️ List all DONE tasks tagged #ProjectX\n\nTab completion for\n- Tags\n- Statuses\n- Arguments" "+60+60"
#annotate "10_list-projectx-done-task-list.gif"
