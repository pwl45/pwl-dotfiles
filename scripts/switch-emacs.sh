#!/bin/bash

# Usage: ./switch-emacs-config [doom|personal]...

# Directory where the actual emacs configurations reside.
CONFIG_DIR="$HOME/.config"

# Link location
EMACS_DIR="$HOME/.config/emacs"

# Remove the existing symlink
rm -f "$EMACS_DIR"

# Create a new symlink based on the argument prefix
if [[ "doom" == "$1"* ]]; then
    ln -s "$CONFIG_DIR/doom-emacs" "$EMACS_DIR"
    echo "Switched to Doom Emacs configuration."
elif [[ "personal" == "$1"* ]]; then
    ln -s "$CONFIG_DIR/personal-emacs" "$EMACS_DIR"
    echo "Switched to Personal Emacs configuration."
else
    echo "Invalid argument. Please use a prefix of 'doom' or 'personal'."
    exit 1
fi
