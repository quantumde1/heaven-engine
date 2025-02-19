# JRPG Engine, called as... meido in Hebun!

![build passing](https://github.com/quantumde1/heaven-engine/actions/workflows/main.yml/badge.svg?event=push)

## Features

- [x] Simple source code with comments(based on raylib by @raysan5)
- [x] Lua scripts
- [x] Control configuration file
- [x] Audio playing
- [x] Battle system
- [x] Main menu
- [x] Personas, skills, load, etc menus
- [x] Loading models and sprites(partially)
- [x] video playback

## Guide

### Building on POSIX

For building, you need install this packages(at least on Alpine linux):
```
lua5.3-dev dub gcc-gdc gcc vlc vlc-dev
```
after installing, in source directory, run for debug build:
```
./build.sh
```
and for production-ready build
```
./build.sh --release
```
Script will done everything automatically(but not installing dependencies, see above)

### Building on Windows

Instuction is slightly harder than for UNIX like OSes.

First, you must get mingw-w64 or other C compiler to compile libhpff from source(you should do it, because prebuilt from repo may work incorrectly).
Next, you must get LDC/DMD/GDC/another D compiler(and if not included, install ```dub```), also you need gitl. Then, you must cd into dir with engine, do git submodule update --init --recursive, and then dub build.

### API
its placed here:
[api](docs/api.md)

## FAQ(maybe, lmao)

### Must I use it?

This engine suitable only for Shin Megami Tensei like JRPGs, not anything else. Also, this engine licensed under MIT, so you can do anything what you want, only giving a credit to me somewhere in your modification/game/etc.

### Why so many dependencies?

Engine built on top of multiple libraries to speed up development. I don't wanna write a new library for playing video and audio synchroniously, or new OpenGL wrapper for simplifying my life.

### Why code is so bad?

I wrote it for myself, and i don't know how to make it better, because i'm newbie in game development. If anyone can help with clearing the code - please, dm me into matrix/telegram.

### Why everything done in one thread?

Because my engine is shitty-coded. Also this will work better on old CPUs.

### Other questions...

if you think you found a bug or you have something tnice to implement, don't be afraid to open an issue or dm me into telegram/matrix!
