#!/usr/bin/env bash
tmux capture-pane -p -S - | tac | awk 'BEGIN{c=0} c==1{print} /⸢.*⸥/{c++} c==2{exit}' | tac | xsel --clipboard --input
