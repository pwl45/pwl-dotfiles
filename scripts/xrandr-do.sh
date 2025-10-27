#!/usr/bin/env bash

status=$( xrandr -q )

# Our custom ordering, optional
declare -a monitor_order=(
"eDP1" # We want this last, that's the most important thing.
"LVDS-1"
"DP1"
"DP2"
"DP-1"
"DP-2"
"DP-3"
"DP1-1"
"DP1-2"
"DP1-3"
"DP2-1"
"DP2-2"
"DP2-3"
"DP-1-1"
"DP-1-3"
"DP-1-2"
"DP-2-1"
"DP-2-2"
"DP-2-3"
"HDMI1"
"HDMI2"
"HDMI-1"
)

readarray -t outputs <<< "$(xrandr -q | grep '^[^ ]\+\s*\(dis\)\?connected' | awk '{print $1}')"
echo "${outputs[@]}"

# Add elements from monitor_order that exist in outputs to sorted array
for mon in "${monitor_order[@]}"; do
    for out in "${outputs[@]}"; do
        if [[ "$mon" == "$out" ]]; then
            sorted+=("$out")
        fi

    done
done

# Add elements from outputs that aren't in monitor_order to sorted array
for out in "${outputs[@]}"; do
    if ! printf '%s\n' "${monitor_order[@]}" | grep -q -P "^$out$"; then
        sorted+=("$out")
    fi
done

# Print the sorted array
echo "sorted: ${sorted[@]}"
# exit 0

xrargs=""
xcoord="0"
for mon in "${sorted[@]}"
do
    if monstat=$( grep "^$mon connected" <<< $status -A 1 ); then
	mode=$( tail -n 1 <<< $monstat | awk '{print $1}')
	num_mons=$((num_mons+1))
	monitor_width=${mode%x*} # from mode {xpos}x{ypos} truncate x{ypos}
	echo "display $mon mode $mode offset ${xcoord}x0"
	xrargs="${xrargs} --output ${mon} --mode $mode --pos ${xcoord}x0 --rotate normal"
	xcoord=$((xcoord+monitor_width))
    else
	xrargs="${xrargs} --output ${mon} --off"
    fi
done


echo "monitors connected: $num_mons"
echo "ending x position: $xcoord"
echo "running xrandr $xrargs"
xrandr $xrargs
