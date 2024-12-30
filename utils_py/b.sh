#!/bin/bash

# Check if the directory is provided as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 /path/to/directory"
    exit 1
fi

# Assign the directory to a variable
DIR="$1"

# Check if the specified directory exists
if [ ! -d "$DIR" ]; then
    echo "Error: Directory $DIR does not exist."
    exit 1
fi

# Find and remove .so files created in the last hour
find "$DIR" -type f -name "*.so" -mmin -60 -exec rm -f {} \;

echo "Removed all .so files created in the last hour from $DIR."

