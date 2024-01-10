#!/bin/sh
ps aux | dmenu -l 56 $DMENUFLAGS | awk '{print $2}' | xargs -r kill
