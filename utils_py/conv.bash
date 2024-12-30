#!/bin/bash

# Loop through all .mp4 files in the current directory
for file in *.mp4; do
    # Check if the file exists to avoid errors if no .mp4 files are found
    if [[ -f "$file" ]]; then
        # Execute ffmpeg command
        ffmpeg -i "$file" -q:v 0 "output_$file"
    else
        echo "No .mp4 files found in the directory."
    fi
done

