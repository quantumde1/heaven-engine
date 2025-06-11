#!/bin/sh

## build script for JSRF-like engine for available platforms. By quantumde1.

case "$1" in
    "dreamcast")
        ## lets try to source default kos toolchain placement
        source /opt/toolchains/dc/kos/environ.sh
        ## if working, go next, otherwise idk
        make -f makefiles/dreamcastMakefile
        rm heaven.cdi
	    sh-elf-objcopy -R .stack -O binary heaven.elf output.bin
        $KOS_BASE/utils/scramble/scramble output.bin 1ST_READ.bin
        mkisofs -joliet-long -C 0,11702 -V "heaven_engine" -G IP.BIN -r -J -l -o ../heaven.iso ./
        cdi4dc ../heaven.iso heaven.cdi
        rm ../heaven.iso
        ;;
    "desktop")
        ## going without anything, lmao
        make -f makefiles/desktopMakefile
        ;;
    "clean")
        make -f makefiles/desktopMakefile clean
        ;;
    *)
        echo "Unknown or empty second argument: $1
available commands is $0 {dreamcast,desktop}"
        ;;
esac
