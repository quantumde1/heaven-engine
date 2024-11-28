#!/bin/sh

set -e  # Exit immediately if a command exits with a non-zero status

RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

# Function to install dependencies
install_dependencies() {
    # Check for sudo or doas
    if command -v sudo > /dev/null; then
        SUDO_CMD="sudo"
    elif command -v doas > /dev/null; then
        SUDO_CMD="doas"
    else
        printf "${RED}[ERROR] Neither sudo nor doas is available. Please install dependencies manually.${RESET}\n"
        return
    fi

    case "$1" in
        "alpine")
            printf "${BLUE}[INFO] Alpine detected!${RESET}\n"
            printf "${BLUE}[INFO] Installing dependencies for Alpine...${RESET}\n"
            $SUDO_CMD apk add dub lua5.3 raylib gcc musl-dev ldc
            ;;
        "arch")
            printf "${BLUE}[INFO] Arch detected!${RESET}\n"
            printf "${BLUE}[INFO] Installing dependencies for Arch...${RESET}\n"
            $SUDO_CMD pacman -S --noconfirm dub lua53 raylib gcc ldc
            ;;
        *)
            printf "${RED}[ERROR] Unsupported OS. Please install dependencies manually.${RESET}\n"
            printf "${BLUE}[INFO] Make sure you have installed dub, liblua5.3, raylib and D compiler!${RESET}\n"
            ;;
    esac
}

# Ask the user if they want to automatically install dependencies
read -p "Do you want to automatically install dependencies? (y/n): " install_deps

if [ "$install_deps" = "y" ]; then
    # Detect the OS
    OS=""
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    fi

    # Install dependencies based on the detected OS
    if [ -n "$OS" ]; then
        install_dependencies "$OS"
    else
        printf "${RED}[ERROR] Unable to detect the operating system.${RESET}\n"
    fi
else
    printf "${YELLOW}[INFO] Skipping dependency installation. Please install them manually if needed.${RESET}\n"
fi

# Check and update git submodules
printf "${BLUE}[INFO] Checking for git submodules...${RESET}\n"
git submodule update --init --recursive

# Change directory to hpff and build
printf "${GREEN}[BUILD] Building hpff...${RESET}\n"
cd hpff/

# Check if libhpff.so already exists
if [ -f "../libhpff.so" ]; then
    printf "${YELLOW}[WARNING] libhpff.so already built. Skipping build process.${RESET}\n"
else
    ./build.sh
    # Move the built library to the parent directory
    mv ./libhpff.so ../
    printf "${GREEN}[SUCCESS] libhpff.so moved to the parent directory.${RESET}\n"
fi

# Return to the original directory
cd ..

# Change directory to libplayback/
cd libplayback/
# Check if libplayback.so already exists
if [ -f "../libplayback.so" ]; then
    printf "${YELLOW}[WARNING] libplayback.so already built. Skipping build process.${RESET}\n"
else
    # Compile with optimization flags
    cc -fPIC -c text.c -O3 -march=native -lraylib -I /opt/local/include -L /opt/local/lib
    gcc -shared -o libplayback.so text.o -O3 -march=native -lraylib -I /opt/local/include -L /opt/local/lib
    # Move the built library to the parent directory
    mv ./libplayback.so ../
    printf "${GREEN}[SUCCESS] libplayback.so moved to the parent directory.${RESET}\n"
fi

# Return to the original directory
cd ..

# Check for the --release flag
if [ "$1" = "--release" ]; then
    BUILD_CMD="dub build --build=release --force"
else
    BUILD_CMD="dub build --force"
fi

# Execute the build command and hide output, but capture errors
printf "${GREEN}[BUILD] Building engine...${RESET}\n"
# check if log file exists
printf "${BLUE}[INFO] If no Build complete shown, then engine not built, check log.txt for details!${RESET}\n"
if [ -f "./log.txt" ]; then
    printf "${YELLOW}[WARNING] log file already exists, continue build...${RESET}\n"
    $BUILD_CMD &> log.txt
else
    printf "${YELLOW}[WARNING] log file does not exist, creating and continue build...${RESET}\n"
    touch log.txt && $BUILD_CMD &> log.txt
fi

# If the build was successful, proceed with further steps
strip ./libplayback.so
strip ./libhpff.so
strip ./heaven-engine
echo "MADE_BY_QUANTUMDE1_UNDERLEVEL_STUDIOS_2024_ALL_RIGHTS_RESERVED_UNDER_MIT_LICENSE_LMAO" >> ./heaven-engine
touch sky.sh && printf "#!/bin/sh\nexec heaven-engine\n" > sky
printf "${GREEN}[BUILD] Build complete!${RESET}\n"
printf "${GREEN}[INFO] All processes completed successfully!${RESET}\n"