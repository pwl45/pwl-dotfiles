#!/usr/bin/bash

status=$( xrandr -q )

# allows user to list monitors by priority
declare -a monitors=(
"DP-1"
"DP-2"
"DP-3"
"HDMI-1"
"LVDS-1"
)

xrargs=""
xcoord="0"
for mon in "${monitors[@]}"
do
    if monstat=$( grep "$mon connected" <<< $status -A 1 ); then
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
