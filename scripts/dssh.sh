#!/usr/bin/env bash

shopt -s nullglob
ssh_files=()
[[ -f ~/.ssh/config.def ]] && ssh_files+=(~/.ssh/config.def)
[[ -f ~/.ssh/config ]]     && ssh_files+=(~/.ssh/config)
ssh_files+=(~/.ssh/config.d/*)

SSH_CMD=ssh
if [[ $1 == '-t' ]]; then
  SSH_CMD="st -e ssh"
fi

grep '^Host' ${ssh_files[@]} -h| grep -v '\*' | awk '{print $2}' | dmenu | xargs $SSH_CMD
