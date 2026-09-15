#!/usr/bin/env bash
set -euo pipefail

if [[ $# -gt 2 ]]; then
    echo "Usage: $0 [initial-environment] [hostname]" >&2
    exit 2
fi

INITIAL_ENVIRONMENT=${1:-desktop}
HOSTNAME_VALUE=${2:-$(hostname)}
USERNAME_VALUE=${USER:-$(whoami)}
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
HOSTS_FILE="$REPO_DIR/hosts.json"

for value in "$HOSTNAME_VALUE" "$USERNAME_VALUE" "$INITIAL_ENVIRONMENT"; do
    if [[ ! "$value" =~ ^[A-Za-z0-9._-]+$ ]]; then
        echo "Invalid host configuration value: $value" >&2
        exit 2
    fi
done

# Keep in sync with `environments` in flake.nix.
case "$INITIAL_ENVIRONMENT" in
    desktop|headless|server|minimal) ;;
    *)
        echo "Invalid Home Manager environment: $INITIAL_ENVIRONMENT" >&2
        exit 2
        ;;
esac

SYSTEM_VALUE=$(nix --extra-experimental-features 'nix-command flakes' eval --impure --raw --expr 'builtins.currentSystem')
if [[ ! "$SYSTEM_VALUE" =~ ^[A-Za-z0-9._-]+$ ]]; then
    echo "Invalid host configuration value: $SYSTEM_VALUE" >&2
    exit 2
fi

if command -v jq >/dev/null 2>&1; then
    JQ=(jq)
else
    JQ=(nix run --inputs-from "$REPO_DIR" nixpkgs#jq --)
fi

TEMP_FILE=$(mktemp "$HOSTS_FILE.tmp.XXXXXX")
trap 'rm -f "$TEMP_FILE"' EXIT

"${JQ[@]}" \
    --arg hostname "$HOSTNAME_VALUE" \
    --arg username "$USERNAME_VALUE" \
    --arg system "$SYSTEM_VALUE" \
    --arg environment "$INITIAL_ENVIRONMENT" \
    '
      if has($hostname) and .[$hostname].system != $system then
        error("host \($hostname) is configured for \(.[$hostname].system), not \($system)")
      else
        .[$hostname] //= { "system": $system, "users": {} }
        | .[$hostname].users[$username].defaultEnvironment //= $environment
      end
    ' "$HOSTS_FILE" > "$TEMP_FILE"

if cmp -s "$HOSTS_FILE" "$TEMP_FILE"; then
    printf '%s@%s\n' "$USERNAME_VALUE" "$HOSTNAME_VALUE"
    exit 0
fi

chmod 0644 "$TEMP_FILE"
mv "$TEMP_FILE" "$HOSTS_FILE"
trap - EXIT
echo "Updated Home Manager host entry: $USERNAME_VALUE@$HOSTNAME_VALUE ($INITIAL_ENVIRONMENT)" >&2
printf '%s@%s\n' "$USERNAME_VALUE" "$HOSTNAME_VALUE"
