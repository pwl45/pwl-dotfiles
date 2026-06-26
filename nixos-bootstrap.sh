#!/usr/bin/env bash
# Bring a host up from the flake: generate its hardware config (first time only),
# rebuild the system, then apply home-manager. Host = $1, or the current hostname.
set -euo pipefail
cd "$(dirname "$0")"
HOST="${1:-$(hostname)}"
HW="system/hosts/$HOST/hardware-configuration.nix"
mkdir -p "$(dirname "$HW")"
if [ ! -f "$HW" ] || grep -q PLACEHOLDER "$HW"; then echo "Generating hardware config -> $HW"; sudo nixos-generate-config --show-hardware-config >"$HW"; fi
echo "Rebuilding system for host: $HOST"
sudo nixos-rebuild switch --flake "./system#$HOST"
echo "Applying home-manager"
home-manager switch --flake .
