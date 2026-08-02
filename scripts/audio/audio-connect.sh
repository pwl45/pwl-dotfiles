#!/usr/bin/env bash
# scripts/audio/audio-connect.sh
# dmenu audio-output picker, mirroring scripts/network/wifi-connect.sh.

status="$HOME/.status-msg"
echo -n "scanning audio outputs..." > "$status"

dump=$(pw-dump)

# Collect available output profiles from ALL audio cards.
# Deduped by (card, dest) — picks the highest-priority profile variant per output on each card.
# USB audio devices (e.g. dock) report available=="unknown" since they can't detect jacks; include those too.
# TSV: <card_id>  <profile_index>  <display_name>
profiles=$(printf '%s' "$dump" | jq -r '
  [ .[] | select(.info.props["media.class"] == "Audio/Device") ] as $devs
  | [ $devs[]
      | .id as $cid
      | (.info.props["device.description"] // "Unknown Device") as $desc
      | .info.params.EnumProfile[]?
      | select(.available != "no" and (.name | startswith("output:")))
      | {cid: $cid, desc: $desc, index, priority, dest: (.name | ltrimstr("output:") | split("+")[0])}
    ]
  | group_by([.cid, .dest])
  | map(max_by(.priority))[]
  | [(.cid|tostring), (.index|tostring), (.desc + ": " + .dest)] | @tsv')

echo "Profiles: $profiles"
choice=$(printf '%s\n' "$profiles" | cut -f3- | dmenu -i -p "audio output:")
[ -z "$choice" ] && { rm -f "$status"; exit 0; }

read -r card index <<< "$(printf '%s\n' "$profiles" | awk -F'\t' -v c="$choice" '$3 == c { print $1, $2; exit }')"

echo -n "switching to $choice..." > "$status"
wpctl set-profile "$card" "$index"

# wpctl set-profile doesn't auto-switch the default sink, so find and set it explicitly
sleep 0.3
sink_id=$(pw-dump | jq -r --argjson cid "$card" '
  .[] | select(
    .info.props["media.class"] == "Audio/Sink" and
    (.info.props["device.id"] | numbers) == $cid
  ) | .id' | head -1)
[ -n "$sink_id" ] && wpctl set-default "$sink_id"

rm -f "$status"
