#!/bin/sh

echo -n "retrieving wifi networks..." > $HOME/.status-msg # updating status

# list networks, skip first line (which is always SSID), exclude lines with --, sort, pipe into dmenu,
# store selected result in variable $netname
netname=$( nmcli -f SSID device wifi list | tail -n +2 | grep -v "^--" | sort | uniq | dmenu | xargs)

echo -n "connecting to $netname..." > $HOME/.status-msg # updating status

# annoying: nmcli doesn't set $? to 1 on failed connection
# so we have to grep for 'success' to determine if connection was successful
# if it fails, dmenu for password connecct using that password
nmcli dev wifi connect "$netname" | grep -qi "secrets.*required" &&
    dmenu -p "password for $netname?" | xargs nmcli dev wifi connect "$netname" password 

rm $HOME/.status-msg
