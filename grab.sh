#!/usr/bin/env bash
getmr() {
    digit_re='^[0-9]+$'
    if [ -z "$2" ]; then
        if [ -z "$1" ]; then # zero
            # zero arguments
            ls --sort=time | head -n 1
            # time find . -maxdepth 1 -printf "%T@\t%f\n" | sort -nr | awk -F '\t' '{print $2}' | head -n 1
        else
            # one argument
            if [[ $1 =~ $digit_re ]] ; then
                # argument is a number: list that many of everything
                ls --sort=time | head -n "$1"
            else
                # argument is not a number
                ls *."$1" --sort=time | head -n 1
            fi
        fi
    else
        # two arguments
        if [[ "$1" =~ $digit_re ]] ; then
            # first is a number: list that many of *."$2"
            ls *."$2" --sort=time | head -n "$1"
        else
            if [[ "$2" =~ $digit_re ]] ; then
                # argument is a number: list that many
                ls *."$1" --sort=time | head -n "$2"
            else
                # neither is a number: warn
                echo "invalid format"
                return 1
            fi
        fi
        # ls *."$1" --sort=time | head -n 1
    fi
}
alias grab=getmr
