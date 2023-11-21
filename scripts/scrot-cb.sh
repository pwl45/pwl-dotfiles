#!/bin/bash

# Define the filename with the current date and time to avoid overwriting
FILENAME="screenshot_$(date +%F_%H-%M-%S).png"

# Take a screenshot using scrot and save it to the defined filename
scrot -s "$FILENAME"

# Copy the screenshot to clipboard using xclip
xclip -selection clipboard -t image/png -i "$FILENAME"

# Remove the screenshot file after copying it to the clipboard
rm "$FILENAME"
