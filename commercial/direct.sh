#!/bin/bash


function annotate() {
  file=$1
  text=$2
  text_position=$3

  text_file="${file/.gif/-text.gif}"

  # Create text
  convert -font Hack-Regular-Nerd-Font-Complete -pointsize 32 -background '#666666' -stroke white -fill white pango:"$text" "$text_file"

  # Add text to frame file
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

annotate "1_create-standup-command.gif" "👆️ Yeah" "+30+30"
#annotate "2_create-standup-note.gif
#annotate "3_list-tasks-command.gif
#annotate "4_list-tasks-before-update.gif
#annotate "5_update-task-call-cindy-1.gif
#annotate "6_update-task-call-cindy-2.gif
#annotate "7_list-tasks-after-update.gif
#annotate "8_list-projectx-done-tasks-command.gif
#annotate "9_list-projectx-done-task-list.gif
