#!/bin/sh

# Loop through all files in the current directory
for file in output_*; do
  # Check if the file exists to avoid errors if no files match
  if [ -e "$file" ]; then
    # Remove the prefix 'output_' and rename the file
    mv "$file" "${file#output_}"
  fi
done

