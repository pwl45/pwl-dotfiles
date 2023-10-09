#!/bin/sh
device=$( nmcli | grep connected | dmenu | cut -d ':' -f1 )
if [ ! -z $device ]; then
    nmcli d $1 $device
else
    echo "Exiting"
fi

