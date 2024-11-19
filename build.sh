#!/bin/sh

RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

printf "${BLUE}[INFO] Be sure you have installed dub, libvlc, liblua5.3, raylib and D compiler!${RESET}\n"

# Check and update git submodules
printf "${BLUE}[INFO] Checking for git submodules...${RESET}\n"
git submodule update --init --recursive
if [ $? -ne 0 ]; then
    printf "${RED}[ERROR] Failed to update git submodules!${RESET}\n"
    exit 1
fi

# Change directory to hpff and build
printf "${GREEN}[BUILD] Building hpff...${RESET}\n"
cd hpff/ || { printf "${RED}[ERROR] Failed to change directory to hpff!${RESET}\n"; exit 1; }

# Check if libhpff.so already exists
if [ -f "../libhpff.so" ]; then
    printf "${YELLOW}[WARNING] libhpff.so already built. Skipping build process.${RESET}\n"
else
    ./build.sh
    if [ $? -ne 0 ]; then
        printf "${RED}[ERROR] hpff build failed!${RESET}\n"
        exit 1
    else
        # Move the built library to the parent directory
        mv ./libhpff.so ../
        if [ $? -eq 0 ]; then
            printf "${GREEN}[SUCCESS] libhpff.so moved to the parent directory.${RESET}\n"
        else
            printf "${RED}[ERROR] Failed to move libhpff.so!${RESET}\n"
            exit 1
        fi
    fi
fi

# Return to the original directory
cd .. || { printf "${RED}[ERROR] Failed to return to the original directory!${RESET}\n"; exit 1; }

# Check if heaven-engine already exists
if [ -f "./heaven-engine" ]; then
    printf "${YELLOW}[WARNING] heaven-engine already built. Skipping build process.${RESET}\n"
else
    # Check for the --release flag
    if [ "$1" = "--release" ]; then
        BUILD_CMD="dub build --build=release"
    else
        BUILD_CMD="dub build"
    fi

    # Execute the build command and hide output, but capture errors
    printf "${GREEN}[BUILD] Building engine...${RESET}\b"
    ERROR_OUTPUT=$($BUILD_CMD)

    if [ $? -eq 0 ]; then
        strip ./heaven-engine
        echo "MADE_BY_QUANTUMDE1_UNDERLEVEL_STUDIOS_2024_ALL_RIGHTS_RESERVED_UNDER_MIT_LICENSE_LMAO" >> ./heaven-engine
        touch sky.sh && printf "#!/bin/sh\nexec heaven-engine\n" > sky.sh && chmod +x sky.sh
        printf "\n${GREEN}[BUILD] Build complete!${RESET}\n"
    else
        printf "${RED}[BUILD] Build incomplete!${RESET}\n\n${YELLOW}[LOGS]${RESET}:\n"
        echo "$ERROR_OUTPUT"
        exit 1
    fi
fi

printf "${GREEN}[INFO] All processes completed successfully!${RESET}\n"
