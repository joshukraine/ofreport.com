#!/bin/bash

# This script is useful for copying the slug name of the latest blog post.
#
# Usage: (from the project root)
# bin/copy_latest_slug
#
# Example output: (from clipboard)
# 2024-11-21-fall-family-photos

# Get the directory of the script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Navigate to the content/articles directory relative to the script's location
cd "$SCRIPT_DIR/../content/articles" || {
  echo "ERROR: Could not navigate to content/articles directory."
  exit 1
}

# Get the newest markdown file, remove the extension, strip newline, and copy to clipboard
eza -s newest -r -- *.md | head -n 1 | sed 's/\.md$//' | tr -d '\n' | pbcopy
