#!/usr/bin/env bash
# Bump claude-code.nix to a newer Claude Code release.
#
# Trust model: both the version number and the sha256 come from Anthropic's
# release CDN (downloads.claude.ai — the same source as claude.ai/install.sh).
# The hash is taken from Anthropic's signed-by-TLS manifest.json, not from
# hashing whatever we happened to download, and is written into the nix file
# as a fixed-output hash, so Nix independently verifies the binary on fetch.
set -euo pipefail

CDN="https://downloads.claude.ai/claude-code-releases"
PLATFORM="linux-x64"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
NIX_FILE="$REPO_DIR/claude-code.nix"

usage() {
    cat <<EOF
Usage: $0 [--check] [--stable] [--version X.Y.Z]

  (no args)        update claude-code.nix to the newest release
  --check          report whether an update is available, change nothing
  --stable         track Anthropic's "stable" channel instead of "latest"
  --version X.Y.Z  pin a specific version
EOF
}

channel="latest"
target_version=""
check_only=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --check) check_only=true; shift ;;
        --stable) channel="stable"; shift ;;
        --version) target_version="$2"; shift 2 ;;
        --help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
    esac
done

current=$(sed -n 's/^ *version = "\([^"]*\)";/\1/p' "$NIX_FILE")

if [ -n "$target_version" ]; then
    new="$target_version"
else
    new=$(curl -sf --max-time 15 "$CDN/$channel")
fi
[[ "$new" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
    echo "Bad version from $CDN/$channel: '$new'" >&2; exit 1;
}

echo "current: $current"
echo "$channel: $new"

if [ "$current" = "$new" ]; then
    echo "Already up to date."
    exit 0
fi

if $check_only; then
    echo "Update available: $current -> $new"
    exit 1
fi

hex=$(curl -sf --max-time 15 "$CDN/$new/manifest.json" \
    | jq -r --arg p "$PLATFORM" '.platforms[$p].checksum')
[[ "$hex" =~ ^[0-9a-f]{64}$ ]] || {
    echo "Bad checksum in manifest for $new/$PLATFORM: '$hex'" >&2; exit 1;
}
sri=$(nix hash convert --hash-algo sha256 --from base16 --to sri "$hex")

sed -i \
    -e "s|^\( *version = \)\"[^\"]*\";|\1\"$new\";|" \
    -e "s|^\( *hash = \)\"[^\"]*\";|\1\"$sri\";|" \
    "$NIX_FILE"

echo "Updated $NIX_FILE: $current -> $new ($sri)"

echo "Verifying build (downloads the binary, ~240MB)..."
nix build --no-link --impure --expr \
    "((import (builtins.getFlake \"$REPO_DIR\").inputs.nixpkgs) {
        system = \"x86_64-linux\"; config.allowUnfree = true;
      }).callPackage $NIX_FILE {}"

echo "Build OK. Run your home-manager switch to install."
