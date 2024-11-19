#!/bin/sh

# Check for the --release flag
if [ "$1" = "--release" ]; then
    BUILD_CMD="dub build --build=release"
else
    BUILD_CMD="dub build"
fi

# Execute the build command and hide output
echo "Building engine..."
if $BUILD_CMD > /dev/null 2>&1; then
    # If build is successful, execute the obfuscator
    echo "Executing obfuscator..."
    if python3 utils/obfuscator.py heaven-engine obfuscated-engine > /dev/null 2>&1; then
        # Move obfuscated-engine to heaven-engine
        mv obfuscated-engine heaven-engine
        echo "Build complete!"
    else
        echo "Build incomplete, see errors above"
    fi
else
    echo "Build incomplete, see errors above"
fi

