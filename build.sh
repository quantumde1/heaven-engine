#!/bin/sh

set -e  # Exit immediately if a command exits with a non-zero status

RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

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

# Change directory to hpff and build
printf "${GREEN}[BUILD] Building raylib...${RESET}\n"
cd raylib/src/

# Check if libhpff.so already exists
if [ -f "../../libraylib.so" ]; then
    printf "${YELLOW}[WARNING] libraylib.so already built. Skipping build process.${RESET}\n"
else
    make PLATFORM=PLATFORM_DESKTOP RAYLIB_LIBTYPE=SHARED -j $(nproc)
    # Move the built library to the parent directory
    mv ./libraylib.so* ../../
    printf "${GREEN}[SUCCESS] libraylib.so and company moved to the parent directory.${RESET}\n"
fi

cd ../../
# Change directory to libplayback/
#cd libplayback/
# Check if libplayback.so already exists
#if [ -f "../libplayback.so" ]; then
#    printf "${YELLOW}[WARNING] libplayback.so already built. Skipping build process.${RESET}\n"
#else
#    # Compile with optimization flags
#    cc -fPIC -c text.c -O3 -march=native -lraylib -I /opt/local/include -L /opt/local/lib
#    gcc -shared -o libplayback.so text.o -O3 -march=native -lraylib -I /opt/local/include -L /opt/local/lib
#    # Move the built library to the parent directory
#    mv ./libplayback.so ../
#    printf "${GREEN}[SUCCESS] libplayback.so moved to the parent directory.${RESET}\n"
#fi

## Return to the original directory
#cd ..

printf "enter repo address with https:\n"
read babah
printf "Done, cloning $babah...\n"
git clone $babah
printf "Move data from cloned folder to current folder with engine binary(aka heaven-engine)\n"
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
#strip ./libplayback.so
strip ./libhpff.so
strip ./heaven-engine
echo "MADE_BY_QUANTUMDE1_UNDERLEVEL_STUDIOS_2024_ALL_RIGHTS_RESERVED_UNDER_MIT_LICENSE_LMAO" >> ./heaven-engine
printf "${GREEN}[BUILD] Build complete!${RESET}\n"
printf "${GREEN}[INFO] All processes completed successfully!${RESET}\n"
