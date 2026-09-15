#!/usr/bin/env bash
# Bring a host up from the flake: generate its hardware config (first time only),
# rebuild the system, then apply home-manager. The host and initial Home Manager
# environment may be passed as the first two arguments.
set -euo pipefail
if [[ $# -gt 2 ]]; then
    echo "Usage: $0 [hostname] [initial-environment]" >&2
    exit 2
fi
cd "$(dirname "$0")"
HOST="${1:-$(hostname)}"
INITIAL_ENVIRONMENT="${2:-desktop}"
HW="system/hosts/$HOST/hardware-configuration.nix"
mkdir -p "$(dirname "$HW")"
if [ ! -f "$HW" ] || grep -q PLACEHOLDER "$HW"; then echo "Generating hardware config -> $HW"; sudo nixos-generate-config --show-hardware-config >"$HW"; fi
echo "Rebuilding system for host: $HOST"
sudo nixos-rebuild switch --flake "./system#$HOST"
echo "Applying home-manager"
SYSTEM="$(uname -m)-linux"
"$PWD/scripts/ensure-home-host.sh" "$HOST" "$(whoami)" "$SYSTEM" "$INITIAL_ENVIRONMENT"
home-manager switch --flake ".#$(whoami)@$HOST"
