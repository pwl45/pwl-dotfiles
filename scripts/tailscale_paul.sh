#!/usr/bin/env bash
set -euo pipefail

sudo -v
umask 077
authkey_file=$(mktemp)
trap 'rm -f "$authkey_file"' EXIT

# Headscale 0.22 can print startup warnings before its JSON output.
ssh -T -o BatchMode=yes alice@auth.paullapey.com \
    'sudo -n /run/current-system/sw/bin/headscale preauthkeys create --user paul --expiration 5m --output json' \
    | grep '^[[:space:]]*"key":' \
    | cut -d '"' -f 4 > "$authkey_file"

test -s "$authkey_file"

sudo tailscale up --force-reauth \
    --hostname "$(hostname)" \
    --login-server "https://auth.paullapey.com" \
    --authkey "file:$authkey_file"
