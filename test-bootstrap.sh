#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="hm-bootstrap-test"

echo "Home Manager Bootstrap Test Script"
echo "=================================="

cleanup() {
    echo "Cleaning up..."
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "Removing container: $CONTAINER_NAME"
        docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
    fi
}

trap cleanup EXIT

check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        echo "Error: Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        echo "Error: Docker daemon is not running or not accessible"
        exit 1
    fi
}

run_test() {
    echo "Starting Ubuntu container..."
    
    docker run -it --name "$CONTAINER_NAME" \
        --volume "$SCRIPT_DIR:/dotfiles:ro" \
        --workdir /home/testuser \
        ubuntu:22.04 \
        bash -c '
            set -euo pipefail
            
            echo "Setting up test environment..."
            apt-get update
            apt-get install -y curl git sudo xz-utils
            
            # Create test user
            useradd -m -s /bin/bash testuser
            usermod -aG sudo testuser
            echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
            
            # Copy dotfiles to test user home
            cp -r /dotfiles /home/testuser/pwl-dotfiles
            chown -R testuser:testuser /home/testuser/pwl-dotfiles
            
            echo "Switching to test user and running bootstrap..."
            # Ensure testuser home directory has correct permissions
            chown -R testuser:testuser /home/testuser
            
            su - testuser -c "
                set -euo pipefail
                cd /home/testuser/pwl-dotfiles
                echo \"Running bootstrap script as testuser...\"
                # Ensure clean environment for Nix installation
                export HOME=/home/testuser
                ./home-manager-bootstrap.sh
                
                echo \"Verifying installation...\"
                if command -v home-manager >/dev/null 2>&1; then
                    echo \"✓ Home Manager installed successfully\"
                    home-manager --version
                else
                    echo \"✗ Home Manager not found in PATH\"
                    exit 1
                fi
                
                if command -v nix >/dev/null 2>&1; then
                    echo \"✓ Nix installed successfully\"
                    nix --version
                else
                    echo \"✗ Nix not found in PATH\"
                    exit 1
                fi
                
                echo \"Bootstrap test completed successfully!\"
            "
        '
}

main() {
    echo "Script directory: $SCRIPT_DIR"
    echo
    
    check_docker
    echo "Docker is available"
    echo
    
    cleanup
    
    run_test
    
    echo
    echo "Test completed successfully!"
    echo "The bootstrap script works correctly in a vanilla Ubuntu environment."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
