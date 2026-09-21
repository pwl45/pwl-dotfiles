#!/usr/bin/env bash

shopt -s nullglob
ssh_files=()
[[ -f ~/.ssh/config ]]     && ssh_files+=(~/.ssh/config)
[[ -f ~/.ssh/config.def ]] && ssh_files+=(~/.ssh/config.def)
ssh_files+=(~/.ssh/config.d/*)

SELECTOR=dmenu

if [[ -n $DISPLAY && -z $SSH_CONNECTION ]]; then
  SELECTOR=dmenu
else
  SELECTOR=fzf
fi

SSH_CMD=(ssh -t)
print_command=false

while (( $# )); do
  case "$1" in
    -t|--terminal) SSH_CMD=(st -e ssh) ;;
    -f|--fzf) SELECTOR=fzf ;;
    -d|--dmenu) SELECTOR=dmenu ;;
    -p|--print) print_command=true ;;
    --) shift; break ;;
    *) printf 'Unexpected argument: %s\n' "$1" >&2; exit 2 ;;
  esac
  shift
done

if (( $# )); then
  printf 'Unexpected argument: %s\n' "$1" >&2
  exit 2
fi

host=$(grep '^Host' "${ssh_files[@]}" -h | grep -v '\*' | awk '{print $2}' | "$SELECTOR")
[[ -n $host ]] || exit 0
if "$print_command"; then
  printf '%q ' "${SSH_CMD[@]}" "$host"
  exit 0
fi
exec "${SSH_CMD[@]}" "$host"
