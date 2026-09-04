#!/usr/bin/env bash
# Fuzzy-find a tmux pane by what is on its screen, then switch to it.
#
# Records are "label<TAB>text<TAB>target", one per scrollback line. fzf's own
# matcher is disabled (--disabled) and each keystroke re-runs --search below;
# that is what lets us collapse the hits to one line per pane, which fzf's
# internal filtering cannot do.
set -uo pipefail

SCROLLBACK=${TMUX_GREP_SCROLLBACK:-400}

# Re-entrant mode: show the tail of a pane, sized to fill the preview window.
# capture-pane pads to the full pane height, so trailing blanks are dropped
# first or a pane holding one prompt line previews as empty space.
if [ "${1:-}" = '--preview' ]; then
    tmux capture-pane -p -e -S "-$SCROLLBACK" -t "$2" 2>/dev/null \
      | awk '
          { line[NR] = $0; if (/[^[:space:]]/) last = NR }
          END {
              n = ENVIRON["FZF_PREVIEW_LINES"] + 0; if (n <= 0) n = 40
              start = last - n + 1; if (start < 1) start = 1
              for (i = start; i <= last; i++) print line[i]
          }'
    exit 0
fi

# Re-entrant mode: grep the prebuilt index, keeping the first hit per pane.
if [ "${1:-}" = '--search' ]; then
    query=${2:-}
    grep -F -i -- "$query" "$TMUX_GREP_INDEX" 2>/dev/null \
      | awk -F'\t' '!seen[$3]++'
    exit 0
fi

index=$(mktemp -t tmux-grep.XXXXXX)
trap 'rm -f "$index"' EXIT

tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index}	#{session_attached}	#{pane_current_command}' \
| while IFS=$'\t' read -r target attached cmd; do
    # Session names share a long "session_" prefix; only the date+pid tail
    # distinguishes them, so drop it for display.
    label=$(printf '%s%s/%s' \
        "$([ "$attached" = 1 ] && printf '*' || printf ' ')" \
        "${target%%:*}" "$cmd")
    label=${label/session_/}

    tmux capture-pane -p -S "-$SCROLLBACK" -t "$target" 2>/dev/null \
    | tr -d '\r' \
    | awk -v lbl="$label" -v tgt="$target" '
        { gsub(/\t/, " "); gsub(/^ +| +$/, "") }
        !NF { next }                   # blank lines carry no search value
        $0 == prev { next }             # collapse repeated prompts/spinners
        { prev = $0; print lbl "\t" $0 "\t" tgt }'
done > "$index"

export TMUX_GREP_INDEX="$index"
self=$(realpath "$0")

target=$("$self" --search '' | fzf \
    --delimiter='\t' \
    --with-nth='1,2' \
    --disabled \
    --reverse \
    --height='100%' \
    --prompt='grep panes> ' \
    --info=inline \
    --bind="change:reload:$self --search {q}" \
    --preview="$self --preview {3}" \
    --preview-window='down,60%,wrap' \
    --header='one hit per pane; * = attached' \
  | cut -f3)

[ -z "$target" ] && exit 0

tmux switch-client -t "$target" 2>/dev/null || tmux attach -t "$target"
