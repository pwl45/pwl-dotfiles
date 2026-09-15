#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="hm-bootstrap-test"
CONTAINER_NAME="hm-bootstrap-test-container"
# Which flake entry to activate: the headless identity by default (fast),
# paul (desktop) with --desktop.
USERNAME="paul.lapey"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --desktop) USERNAME="paul" ;;
        *) echo "Usage: $0 [--desktop]" >&2; exit 1 ;;
    esac
    shift
done

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
    echo "Building test Docker image (user: $USERNAME)..."
    docker build --build-arg USERNAME="$USERNAME" -f "$SCRIPT_DIR/Dockerfile.test" -t "$IMAGE_NAME" "$SCRIPT_DIR"

    echo "Running bootstrap test in container..."
    # Bootstrap and verify in a single `docker run`: the container exits with
    # the bootstrap script, so there is no running container to `docker exec`
    # into afterwards.
    docker run --name "$CONTAINER_NAME" --hostname home-manager-bootstrap-test "$IMAGE_NAME" bash -c '
        set -euo pipefail
        export USER="$(whoami)"

        if [[ "$USER" == "paul.lapey" ]]; then
            ./home-manager-bootstrap.sh headless
        else
            ./home-manager-bootstrap.sh desktop
        fi

        echo "Verifying bootstrap results..."
        # Single-user Nix installed by the bootstrap is not on PATH in this shell.
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
        export PATH="$HOME/.nix-profile/bin:$PATH"
        nix --version
        echo "✓ Nix installed successfully"

        # A completed `home-manager -- switch` leaves this profile symlink
        # pointing at a store generation.
        generation="$(readlink -f "$HOME/.local/state/nix/profiles/home-manager")"
        case "$generation" in
            /nix/store/*home-manager-generation) ;;
            *)
                echo "✗ Home Manager generation not activated"
                exit 1
                ;;
        esac
        echo "✓ Home Manager generation activated: $generation"

        # The re-apply path must work: home-manager must run from the flake.
        generations="$(nix run --inputs-from "$HOME/pwl-dotfiles" home-manager -- generations)"
        [[ -n "$generations" ]] || { echo "✗ Home Manager reported no generations"; exit 1; }
        echo "✓ Home Manager runs from the flake:"
        echo "$generations"
    '
}

main() {
    echo "Script directory: $SCRIPT_DIR"
    echo "Testing as user: $USERNAME"
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
