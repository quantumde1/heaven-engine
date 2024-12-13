@echo off
setlocal enabledelayedexpansion

REM Exit immediately if a command exits with a non-zero status
set "RED=^[[31m"
set "GREEN=^[[32m"
set "YELLOW=^[[33m"
set "BLUE=^[[34m"
set "RESET=^[[0m"

REM Check and update git submodules
echo !BLUE![INFO] Checking for git submodules...!RESET!
git submodule update --init --recursive

REM Change directory to hpff and build
echo !GREEN![BUILD] Building hpff...!RESET!

REM Check for the --release flag
set "BUILD_CMD=dub build --force"
if "%~1"=="--release" (
    set "BUILD_CMD=dub build --build=release --force"
)

REM Execute the build command and hide output, but capture errors
echo !GREEN![BUILD] Building engine...!RESET!
echo !BLUE![INFO] If no Build complete shown, then engine not built, check log.txt for details.!RESET!
if exist "log.txt" (
    echo !YELLOW![WARNING] log file already exists, continue build...!RESET!
    %BUILD_CMD% > log.txt 2>&1
) else (
    echo !YELLOW![WARNING] log file does not exist, creating and continue build...!RESET!
    echo. > log.txt
    %BUILD_CMD% > log.txt 2>&1
)

REM If the build was successful, proceed with further steps
REM strip ./libplayback.so
strip libhpff.so
strip heaven-engine
echo MADE_BY_QUANTUMDE1_UNDERLEVEL_STUDIOS_2024_ALL_RIGHTS_RESERVED_UNDER_MIT_LICENSE_LMAO >> heaven-engine
echo #!/bin/sh > sky.bat
echo exec heaven-engine >> sky.bat
echo !GREEN![BUILD] Build complete.!RESET!
echo !GREEN![INFO] All processes completed successfully.!RESET!

endlocal
