#!/bin/bash
#
# Home Manager bootstrap for Linux and macOS. Installs Nix, enables flakes,
# selects the flake entry for the current username/platform, and activates via
# `nix run home-manager`. The only per-platform differences live in the case
# block below; everything after it is shared.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Home Manager Bootstrap"
echo "======================"

export USER=${USER:-$(whoami)}

# Installation differs by OS; package profiles live in flake.nix.
case "$(uname -s)" in
    Linux) NIX_FLAG="--no-daemon" ;;
    Darwin) NIX_FLAG="--daemon" ;;
    *) echo "Unsupported OS: $(uname -s)"; exit 1 ;;
esac

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
    if [[ -d "$HOME/.nix-profile/bin" ]]; then
        export PATH="$HOME/.nix-profile/bin:$PATH"
    fi
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

switch_to_flake() {
    source_nix
    local platform configuration
    platform=$(nix --extra-experimental-features 'nix-command flakes' eval --impure --raw --expr 'builtins.currentSystem')
    configuration="${USER:-$(whoami)}@$platform"
    echo "Activating Home Manager: $configuration"
    # -b backup renames pre-existing files HM would refuse to overwrite.
    # Username may contain a dot, so quote it in the flake ref.
    nix run home-manager -- switch -b backup --flake "$SCRIPT_DIR#$configuration"
    echo "Home Manager configuration applied."
}

main() {
    echo "Script directory: $SCRIPT_DIR"
    echo
    install_nix
    echo
    configure_nix
    echo
    switch_to_flake
    echo
    echo "Done. Open a new terminal so the Nix profile and PATH take effect."
    echo "Re-apply later with: hsf"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
