#!/bin/bash

# Get window id
# xprop
#
# Set window to size
# xdotool selectwindow windowsize 804 458
#
# Take screenshot
#import -window 0x3e0001e 1.png

set -e

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

cp screenshots/* frames/.

# Chop off title bar and scroll bar
#for i in *.gif; do
#  convert $i -gravity East -chop 10x0 ../frames/$i 
#  convert ../frames/$i -chop 0x25 ../frames/$i
#done

cd frames

annotate "01_create-standup-command.gif" "👆️ Create a new note named standup" "+40+40"
annotate "02_create-standup-note.gif" "Note opens in Vim, this is configurable😱😍\n\nThis note contains a task and some meeting notes" "+80+140"
annotate "03_create-standup-note.gif" "Notes are plain text files\n\nTasks are any line containing a valid Status\n\nAdd #hashtags anywhere to create tags" "+100+160"
annotate "04_list-tasks-command.gif" "👆️ List open tasks found in the notes" "+40+40"
annotate "05_list-tasks-fzf.gif" "Type to filter tasks\n\nArrow keys + Enter to select" "+40+200"
annotate "06_list-tasks-before-update.gif" "👇️ Cindy task is done, lets update it💪\n\nSelect task + Enter to open note in Vim" "+140+258"
annotate "07_update-task-call-cindy-1.gif" "Vim opens on line 15👌\n\nChange TODO to DONE" "+270+280"
annotate "08_update-task-call-cindy-2.gif" "✅👍️" "+360+310"
annotate "09_note-markup.gif" "Dun syntax should play nice with your\npreferred note taking markup👌" "+200+80"
annotate "10_list-tasks-after-update.gif" "Closing Vim returns to updated task list💫" "+100+200"

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
frames/05_list-tasks-fzf.gif \
-d 1200 \
frames/06_list-tasks-before-update.gif \
-d 800 \
frames/07_update-task-call-cindy-1.gif \
-d 500 \
frames/08_update-task-call-cindy-2.gif \
-d 750 \
frames/09_note-markup.gif \
frames/10_list-tasks-after-update.gif \
> dun-commercial.gif 

