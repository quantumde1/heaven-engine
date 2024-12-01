#!/bin/bash

# Check if two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <first_directory> <second_directory>"
    exit 1
fi

# Assign arguments to variables
DIR1="$1"
DIR2="$2"

# Check if both directories exist
if [ ! -d "$DIR1" ]; then
    echo "Error: Directory '$DIR1' does not exist."
    exit 1
fi

if [ ! -d "$DIR2" ]; then
    echo "Error: Directory '$DIR2' does not exist."
    exit 1
fi

# Loop through files in the first directory
for file in "$DIR1"/*; do
    # Get the base name of the file
    filename=$(basename "$file")
    
    # Check if the file exists in the second directory
    if [ -e "$DIR2/$filename" ]; then
        echo "Removing '$DIR2/$filename' as it exists in '$DIR1'."
        rm "$DIR2/$filename"
    fi
done

echo "Comparison and removal complete."

