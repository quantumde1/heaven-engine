#!/bin/bash

# Loop through all files in the current directory
for file in cropped_*; do
    # Check if the file exists (in case there are no matching files)
    if [[ -e "$file" ]]; then
        # Remove the 'cropped_' prefix
        new_name="${file#cropped_}"
        # Rename the file
        mv "$file" "$new_name"
        echo "Renamed '$file' to '$new_name'"
    fi
done

