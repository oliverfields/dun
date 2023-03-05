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
annotate "02_create-standup-note.gif" "👆️ Note opens in Vim\n\nHere a new task has been\nadded with status TODO" "+80+40"
annotate "03_create-standup-note.gif" "Tasks are any line containing a valid Status\n\nAdd #hashtags anywhere to create tags\n\nNotes are plain text files" "+100+60"
annotate "04_list-tasks-command.gif" "👆️ List open tasks from all notes files" "+40+40"
annotate "05_list-tasks-before-update.gif" "👈️ Cindy task is done💪\nType 1 + Enter to\nopen note in Vim" "+440+70"
annotate "06_update-task-call-cindy-1.gif" "Vim opens on line 15👌\nChange TODO to DONE\nto close task" "+270+300"
annotate "07_update-task-call-cindy-2.gif" "✅👍️" "+360+310"
annotate "08_note-markup.gif" "Dun should play nice with your\npreferred note taking markup👌" "+300+80"
annotate "09_list-tasks-after-update.gif" "Closing Vim returns to\nupdated task list💫" "+450+110"

cd ..
gifsicle --loopcount=forever --colors 256 \
-d 250 title.gif \
-d 500 \
frames/01_create-standup-command.gif \
-d 800 \
frames/02_create-standup-note.gif \
-d 800 \
frames/03_create-standup-note.gif \
-d 500 \
frames/04_list-tasks-command.gif \
-d 1200 \
frames/05_list-tasks-before-update.gif \
-d 800 \
frames/06_update-task-call-cindy-1.gif \
-d 500 \
frames/07_update-task-call-cindy-2.gif \
-d 750 \
frames/08_note-markup.gif \
frames/09_list-tasks-after-update.gif \
> dun-commercial.gif 

