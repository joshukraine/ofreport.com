#!/bin/bash

# Dynamically set the current year
CURRENT_YEAR=$(date +%Y)

# Define directories to exclude explicitly
EXCLUDE_DIRS=(".git" "node_modules" ".nuxt" "dist" "coverage" ".husky")

# Build the find command exclusions
FIND_EXCLUDES=""
for dir in "${EXCLUDE_DIRS[@]}"; do
  FIND_EXCLUDES+="! -path \"*/$dir/*\" "
done

# Find all files containing "Copyright (c)", excluding specified directories
eval "find . -type f $FIND_EXCLUDES" | while read -r file; do
  # Extract and update copyright years in matching files
  if grep -qE "Copyright \(c\) [0-9]{4}–[0-9]{4}" "$file"; then
    # Update the end year in ranges (e.g., 2019–2021 -> 2019–2025)
    sed -i '' -E "s/(Copyright \(c\) [0-9]{4})–[0-9]{4}/\1–$CURRENT_YEAR/" "$file"
    echo "Updated: $file"
  elif grep -qE "Copyright \(c\) [0-9]{4}" "$file"; then
    # Convert single years into a range ending in 2025 (e.g., 2019 -> 2019–2025)
    sed -i '' -E "s/(Copyright \(c\) [0-9]{4})/\1–$CURRENT_YEAR/" "$file"
    echo "Updated: $file"
  fi
done

echo "Copyright update complete!"
