#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Home Manager Bootstrap Script"
echo "============================="

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

install_nix() {
    echo "Installing Nix package manager..."
    
    if check_command nix; then
        echo "Nix is already installed, skipping installation."
        return 0
    fi
    
    # Clean up any existing Nix profile locks and state
    echo "Cleaning up any existing Nix state..."
    rm -f "$HOME/.nix-profile.lock" 2>/dev/null || true
    rm -f "$HOME/.nix-defexpr.lock" 2>/dev/null || true
    rm -rf "$HOME/.nix-defexpr" 2>/dev/null || true
    rm -rf "$HOME/.nix-profile" 2>/dev/null || true
    
    sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon --yes
    
    echo "Sourcing Nix environment..."
    if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    elif [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
        source "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi
    
    if ! check_command nix; then
        echo "Error: Nix installation failed or not in PATH"
        echo "Please restart your shell and run this script again"
        exit 1
    fi
    
    echo "Nix installed successfully!"
}

install_home_manager() {
    echo "Installing Home Manager..."
    
    if check_command home-manager; then
        echo "Home Manager is already installed, skipping installation."
        return 0
    fi
    
    echo "Adding Home Manager channel..."
    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --update
    
    echo "Installing Home Manager..."
    nix-shell '<home-manager>' -A install
    
    if ! check_command home-manager; then
        echo "Error: Home Manager installation failed"
        exit 1
    fi
    
    echo "Home Manager installed successfully!"
}

configure_nix() {
    echo "Configuring Nix with experimental features..."
    
    mkdir -p "$HOME/.config/nix"
    
    cat > "$HOME/.config/nix/nix.conf" << 'EOF'
experimental-features = nix-command flakes
EOF
    
    echo "Nix configuration updated to enable flakes and nix-command"
}

switch_to_flake() {
    echo "Switching to flake configuration..."
    
    if [[ ! -f "$SCRIPT_DIR/flake.nix" ]]; then
        echo "Error: flake.nix not found in $SCRIPT_DIR"
        exit 1
    fi
    
    if [[ ! -f "$SCRIPT_DIR/home.nix" ]]; then
        echo "Error: home.nix not found in $SCRIPT_DIR"
        exit 1
    fi
    
    echo "Configuring flake for user: $USER"
    cd "$SCRIPT_DIR"
    
    # Update flake.nix to use current user
    sed -i "s/mkHomeConfiguration \".*\"/mkHomeConfiguration \"$USER\"/" flake.nix
    
    echo "Running home-manager switch with flake..."
    
    if ! nix flake check; then
        echo "Warning: Flake check failed, but continuing anyway..."
    fi
    
    home-manager switch --flake ".#$USER"
    echo "Home Manager configuration applied successfully!"
}

main() {
    echo "Starting bootstrap process..."
    echo "Script directory: $SCRIPT_DIR"
    echo
    
    install_nix
    echo
    
    configure_nix
    echo
    
    install_home_manager
    echo
    
    switch_to_flake
    echo
    
    echo "Bootstrap completed successfully!"
    echo "Your Home Manager configuration is now active."
    echo
    echo "Note: You may need to restart your shell or log out/in for all changes to take effect."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
