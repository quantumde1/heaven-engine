#!/bin/sh

# Variables
SRC="src/lib.c"
LIB_NAME="libhpff.so"
INSTALL_DIR="/usr/local/lib"

# Function to build the shared library
build() {
    echo "Building shared library..."
    gcc -march=native -O3 -fPIC -shared -o "$LIB_NAME" "$SRC"
    if [ $? -ne 0 ]; then
        echo "Build failed!"
        exit 1
    fi
    echo "Build successful: $LIB_NAME"
}

# Function to install the library
install() {
    if [ -d /usr/local/lib ]; then
        echo "Installing to /usr/local/lib"
        cp "$LIB_NAME" /usr/local/lib
    else
        echo "Installing to /usr/lib"
        cp "$LIB_NAME" /usr/lib
    fi
    ldconfig
    echo "Installation successful."
}

# Main script logic
if [ "$1" = "install" ]; then
    build
    install
else
    build
fi
