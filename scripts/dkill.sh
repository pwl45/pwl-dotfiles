#!/bin/sh
ps aux | flexmenu -l 56 $DMENUFLAGS | awk '{print $2}' | xargs -r kill
