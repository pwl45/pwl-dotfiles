#!/bin/bash
#
# Home Manager bootstrap for Linux and macOS. Installs Nix, enables flakes,
# rewrites the flake's user/system/environment hooks, and activates via
# `nix run home-manager`. The only per-platform differences live in the case
# block below; everything after it is shared.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Home Manager Bootstrap"
echo "======================"

USERNAME=${USER:-$(whoami)}
export USER=${USER:-$(whoami)}

# Per-platform knobs: install mode, default environment, sed flavor, system.
case "$(uname -s)" in
    Linux)
        NIX_FLAG="--no-daemon"          # single-user: intentional for containers/servers
        DEFAULT_ENV="server"
        sedi() { sed -i "$@"; }         # GNU sed
        case "$(uname -m)" in
            x86_64)  SYSTEM="x86_64-linux" ;;
            aarch64) SYSTEM="aarch64-linux" ;;
            *) echo "Unsupported Linux arch: $(uname -m)"; exit 1 ;;
        esac
        ;;
    Darwin)
        NIX_FLAG="--daemon"             # multi-user is mandatory (read-only system volume)
        DEFAULT_ENV="macos"
        sedi() { sed -i '' "$@"; }      # BSD sed
        case "$(uname -m)" in
            arm64)  SYSTEM="aarch64-darwin" ;;
            x86_64) SYSTEM="x86_64-darwin" ;;
            *) echo "Unsupported macOS arch: $(uname -m)"; exit 1 ;;
        esac
        ;;
    *) echo "Unsupported OS: $(uname -s)"; exit 1 ;;
esac

INSTALL_ENVIRONMENT=${INSTALL_ENVIRONMENT:-"$DEFAULT_ENV"}

check_command() { command -v "$1" >/dev/null 2>&1; }

# Bring an installed Nix onto PATH for this shell (daemon or single-user).
source_nix() {
    if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        # shellcheck disable=SC1091
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    elif [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
        # shellcheck disable=SC1091
        source "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi
    [[ -d "$HOME/.nix-profile/bin" ]] && export PATH="$HOME/.nix-profile/bin:$PATH"
}

install_nix() {
    echo "Installing Nix ($NIX_FLAG)..."
    if check_command nix; then
        echo "Nix already installed, skipping."
        return 0
    fi

    # A single-user re-install needs a clean slate (fresh containers, etc.).
    if [[ "$NIX_FLAG" == "--no-daemon" ]]; then
        rm -f  "$HOME/.nix-profile.lock" "$HOME/.nix-defexpr.lock" 2>/dev/null || true
        rm -rf "$HOME/.nix-defexpr" "$HOME/.nix-profile" 2>/dev/null || true
    fi

    sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) "$NIX_FLAG" --yes

    source_nix
    if ! check_command nix; then
        echo "Error: Nix not on PATH after install."
        echo "Open a new terminal so the profile loads, then re-run this script."
        exit 1
    fi
    echo "Nix installed."
}

configure_nix() {
    echo "Enabling flakes + nix-command..."
    mkdir -p "$HOME/.config/nix"
    cat > "$HOME/.config/nix/nix.conf" << 'EOF'
experimental-features = nix-command flakes
EOF
}

apply_hooks() {
    echo "Configuring flake: user=$USERNAME system=$SYSTEM env=$INSTALL_ENVIRONMENT"
    [[ -f "$SCRIPT_DIR/flake.nix" ]] || { echo "flake.nix not found in $SCRIPT_DIR"; exit 1; }
    [[ -f "$SCRIPT_DIR/home.nix"  ]] || { echo "home.nix not found in $SCRIPT_DIR"; exit 1; }
    cd "$SCRIPT_DIR"

    sedi "s/mkHomeConfiguration \".*\"; # REPLACE_USERNAME_HOOK/mkHomeConfiguration \"$USERNAME\"; # REPLACE_USERNAME_HOOK/" flake.nix
    sedi "s/system = \".*\"; # REPLACE_SYSTEM_HOOK/system = \"$SYSTEM\"; # REPLACE_SYSTEM_HOOK/" flake.nix
    sedi "s/environment = \".*\"; # REPLACE_ENVIRONMENT_HOOK/environment = \"$INSTALL_ENVIRONMENT\"; # REPLACE_ENVIRONMENT_HOOK/" home.nix
}

switch_to_flake() {
    source_nix
    echo "Activating Home Manager..."
    # -b backup renames pre-existing files HM would refuse to overwrite.
    # Username may contain a dot, so quote it in the flake ref.
    nix run home-manager -- switch -b backup --flake ".#$USERNAME"
    echo "Home Manager configuration applied."
}

main() {
    echo "Script directory: $SCRIPT_DIR"
    echo
    install_nix
    echo
    configure_nix
    echo
    apply_hooks
    echo
    switch_to_flake
    echo
    echo "Done. Open a new terminal so the Nix profile and PATH take effect."
    echo "Re-apply later with:  home-manager switch --flake .#\"$USERNAME\""
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
