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

  # Tidy up
  rm "$text_file"
}


if [ -d "frames" ]; then
  rm frames/*
else
  mkdir frames
fi

cd screenshots || exit 1

# Chop off title bar and scroll bar
for i in *.gif; do
  convert $i -gravity East -chop 10x0 ../frames/$i 
  convert ../frames/$i -chop 0x25 ../frames/$i
done

cd ../frames

annotate "01_create-standup-command.gif" "👆️ Create a new note named standup" "+40+40"
annotate "02_create-standup-note.gif" "👆️ Note opens in vi, add a new task\nwith status TODO\n\nTasks are any line containing a valid Status\n\nAdd #hashtags anywhere to create tags\n\nNotes are plain text files" "+80+40"
annotate "03_list-tasks-command.gif" "👆️ List open tasks from all notes files" "+40+40"
annotate "04_list-tasks-before-update.gif" "👈️ Cindy task is done💪\nType 1 + Enter to\nopen note in vi" "+440+70"
annotate "05_update-task-call-cindy-1.gif" "Vi opens on line 15👌\nChange TODO to DONE\nto close task" "+270+300"
annotate "06_update-task-call-cindy-2.gif" "✅👍️" "+360+310"
annotate "07_note-markup.gif" "Notes are just plain text files.\nDun should play nice with your\npreferred note taking markup👌" "+300+80"
annotate "08_list-tasks-after-update.gif" "Closing vi returns to\nupdated task list💫" "+450+110"
#annotate "09_list-projectx-done-tasks-command.gif" "👆️ List all DONE tasks tagged #ProjectX\n\nTab completion for\n- Tags\n- Statuses\n- Arguments" "+40+40"
#annotate "10_list-projectx-done-task-list.gif" "DONE🤩" "+520+40"

cd ..
gifsicle --loopcount=forever --colors 256 \
-d 250 title.gif \
-d 500 \
frames/01_create-standup-command.gif \
-d 1500 \
frames/02_create-standup-note.gif \
-d 500 \
frames/03_list-tasks-command.gif \
-d 1200 \
frames/04_list-tasks-before-update.gif \
-d 800 \
frames/05_update-task-call-cindy-1.gif \
-d 500 \
frames/06_update-task-call-cindy-2.gif \
-d 750 \
frames/07_note-markup.gif \
frames/08_list-tasks-after-update.gif \
> dun-commercial.gif 

