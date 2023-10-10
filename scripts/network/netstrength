#!/bin/bash
#COLOR=^c#FFF7D4^
# COLOR=
# if [[ $(pacmd list-sinks | grep -c "muted: yes") > 0 ]]; then
# 	echo "🔇"
# 	exit
# fi
dev=$( ip route show | awk '{print $5; exit 0}' )
# echo $dev

# network strength is measured out of 70
if [[ $dev =~ ^e ]] ; then
	network='Ethernet'
	STRENGTH=70
else
	network=$( iwgetid -r )
	# cat /proc/net/wireless
	STRENGTH=$( awk -v dev=$dev '$0 ~ dev { gsub("\\.","",$3); print $3  }' /proc/net/wireless )

fi

# STRENGTH=$1
# echo $STRENGTH
# if [[ -z $STRENGTH ]]; then
# 	echo " %"
# 	exit
# fi

# echo $STRENGTH
echo "$network: $((STRENGTH*100/70))%"
# STRENGTH_BAR=""
# (( $STRENGTH > 00 )) && X=0 && STRENGTH_BAR+="^C10^^r${X},14,2,02^"
# (( $STRENGTH > 10 )) && X=3 && STRENGTH_BAR+="^C4^^r${X},12,2,04^"
# (( $STRENGTH > 20 )) && X=6 && STRENGTH_BAR+="^C10^^r${X},10,2,06^"
# (( $STRENGTH > 30 )) && X=9 && STRENGTH_BAR+="^C4^^r${X},08,2,08^"
# (( $STRENGTH > 40 )) && X=12 && STRENGTH_BAR+="^C10^^r${X},06,2,10^"
# (( $STRENGTH > 50 )) && X=15 && STRENGTH_BAR+="^C4^^r${X},04,2,12^"
# (( $STRENGTH > 60 )) && X=18 && STRENGTH_BAR+="^C10^^r${X},02,2,14^"

# STRENGTH_BAR+="^d^^f$(($X+8))^"
# echo "${STRENGTH_BAR}${COLOR}^d^ ${network}"
