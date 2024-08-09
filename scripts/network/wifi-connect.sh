#!/usr/bin/env bash

echo -n "retrieving wifi networks..." > $HOME/.status-msg # updating status

# list networks with SSID and security type, skip first line, exclude lines with --, sort, pipe into dmenu,
# store selected result in variable $network_info
network_info=$(nmcli -t -f SSID,SECURITY device wifi list | tail -n +2 | grep -v "^--" | sort | uniq | sed 's/:.\+/: [X]/g ; s/:$/: [O]/g' | dmenu)
 
# Extract SSID and security type
netname=$(echo "$network_info" | cut -d ':' -f 1)
security=$(echo "$network_info" | cut -d ':' -f 2)

echo $netname
echo $security


echo -n "connecting to $netname..." > $HOME/.status-msg # updating status

nmcli dev wifi connect "$netname" 2>&1 | grep -qi "secrets.*required" &&
    dmenu -p "password for $netname?" | xargs nmcli dev wifi connect "$netname" password 

rm $HOME/.status-msg
