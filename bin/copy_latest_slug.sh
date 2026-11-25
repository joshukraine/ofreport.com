#!/bin/bash
#
# Copy the slug of the latest blog post to the clipboard, e.g. for naming the
# post's Cloudinary folder. "Latest" means the last filename in date order, so
# a future-dated post counts and editing an older post doesn't.
#
# Usage (from anywhere): bin/copy_latest_slug.sh

set -euo pipefail

blog_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../content/blog" && pwd)"

slug="$(find "$blog_dir" -maxdepth 1 -name '[0-9][0-9][0-9][0-9]-*.md' -exec basename {} .md \; | sort | tail -n 1)"

if [[ -z "$slug" ]]; then
  echo "ERROR: No dated posts found in $blog_dir" >&2
  exit 1
fi

printf '%s' "$slug" | pbcopy
echo "Copied: $slug"
