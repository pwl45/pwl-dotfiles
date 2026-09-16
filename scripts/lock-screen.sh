#!/bin/sh

if [ -x /run/wrappers/bin/slock ]; then
    exec /run/wrappers/bin/slock
fi

exec /usr/bin/i3lock -u -c 000000
