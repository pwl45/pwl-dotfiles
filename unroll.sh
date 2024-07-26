#!/bin/bash

unroll() {
    # Check if an argument is provided
    if [ $# -eq 0 ]; then
        echo "Error: No directory specified." >&2
        echo "Usage: unroll <directory>" >&2
        return 1
    fi

    parent_dir="$1"

    # Check if the parent directory exists
    if [ ! -d "$parent_dir" ]; then
        echo "Error: '$parent_dir' is not a directory." >&2
        return 1
    fi

    # Count the number of items in the parent directory
    item_count=$(find "$parent_dir" -mindepth 1 -maxdepth 1 | wc -l)

    # Check if the parent directory contains exactly one item
    if [ "$item_count" -ne 1 ]; then
        echo "Error: '$parent_dir' should contain exactly one subdirectory." >&2
        return 1
    fi

    # Get the child directory
    child_dir=$(find "$parent_dir" -mindepth 1 -maxdepth 1 -type d)

    # Check if the single item is a directory
    if [ ! -d "$child_dir" ]; then
        echo "Error: The item in '$parent_dir' is not a directory." >&2
        return 1
    fi

    # Move all contents from child to parent
    mv "$child_dir"/* "$parent_dir"/ 2>/dev/null
    mv "$child_dir"/.* "$parent_dir"/ 2>/dev/null

    # Remove the now-empty child directory
    rmdir "$child_dir"

    echo "Successfully unrolled '$parent_dir'."
}
