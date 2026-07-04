#!/usr/bin/env bash
# scripts/audio/audio-connect.sh
# dmenu audio-output picker, mirroring scripts/network/wifi-connect.sh.

status="$HOME/.status-msg"
echo -n "scanning audio outputs..." > "$status"

# the sound card's pipewire device id
card=$(pw-dump | jq 'first(.[] | select(.info.props["media.class"] == "Audio/Device") | .id)')

# available output profiles as "<index><TAB><name>", one row per output: the
# highest-priority variant per destination (which keeps the mic on), labelled
# with pipewire's own profile name minus the redundant "+input:..." half.
profiles=$(pw-dump | jq -r --argjson c "$card" '
  [ .[] | select(.id == $c) | .info.params.EnumProfile[]
    | select(.available == "yes" and (.name | startswith("output:"))) ]
  | group_by(.name | split("+")[0])
  | map(max_by(.priority))[]
  | [.index, (.name | ltrimstr("output:") | split("+")[0])] | @tsv')

choice=$(printf '%s\n' "$profiles" | cut -f2- | dmenu -i -p "audio output:")
[ -z "$choice" ] && { rm -f "$status"; exit 0; }

index=$(printf '%s\n' "$profiles" | awk -F'\t' -v c="$choice" '$2 == c { print $1; exit }')

echo -n "switching to $choice..." > "$status"
wpctl set-profile "$card" "$index"   # the new sink auto-becomes the default output

rm -f "$status"
