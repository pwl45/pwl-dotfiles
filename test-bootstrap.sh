#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="hm-bootstrap-test"
CONTAINER_NAME="hm-bootstrap-test-container"

echo "Home Manager Bootstrap Test Script"
echo "=================================="

cleanup() {
    echo "Cleaning up..."
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "Removing container: $CONTAINER_NAME"
        docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
    fi
    
    if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_NAME}:latest$"; then
        echo "Removing image: $IMAGE_NAME"
        docker rmi "$IMAGE_NAME" >/dev/null 2>&1 || true
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

build_and_run_test() {
    echo "Building test Docker image..."
    cd "$SCRIPT_DIR"
    
    docker build -f Dockerfile.test -t "$IMAGE_NAME" .
    
    echo "Running bootstrap test in container..."
    docker run --name "$CONTAINER_NAME" "$IMAGE_NAME"
    
    echo "Verifying installation in container..."
    docker exec "$CONTAINER_NAME" bash -c '
        if command -v home-manager >/dev/null 2>&1; then
            echo "✓ Home Manager installed successfully"
            home-manager --version
        else
            echo "✗ Home Manager not found in PATH"
            exit 1
        fi
        
        if command -v nix >/dev/null 2>&1; then
            echo "✓ Nix installed successfully"  
            nix --version
        else
            echo "✗ Nix not found in PATH"
            exit 1
        fi
        
        echo "Bootstrap test completed successfully!"
    '
}

main() {
    echo "Script directory: $SCRIPT_DIR"
    echo
    
    check_docker
    echo "Docker is available"
    echo
    
    cleanup
    
    build_and_run_test
    
    echo
    echo "Test completed successfully!"
    echo "The bootstrap script works correctly in a vanilla Ubuntu environment."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi