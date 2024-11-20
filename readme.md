# Heaven engine(Meido in Hebun!)

![build passing](https://github.com/quantumde1/heaven-engine/actions/workflows/main.yml/badge.svg?event=push)
![lines of code](https://img.shields.io/endpoint?url=https://ghloc.vercel.app/api/quantumde1/heaven-engine/badge)
Engine, developed primarly for Sky game series. Its now in state of active development, game too :)

## Features
Features, available now:
- [x] Simple source code with comments(based on raylib by @raysan5)
- [x] Lua scripts (only few functions implemented)
- [x] Control configuration file
- [x] Audio playing
- [x] Battle system
- [x] Main menu
- [ ] Pause menu
- [ ] Personas, skills, load, etc menus
- [x] Loading models and sprites(partially)
- [x] video playback

## Simple docs!

### Building

For building, you need install this packages(at least on Alpine linux):
```
apk add raylib-dev lua5.4-dev dub ldc alpine-sdk vlc
```
after this, in source directory, run for debug:
```
dub build --force //Compiler must me LDC2/GDC, DMD isn't working!
```
and for release
```
dub build --build=release
```
On windows, instructions is similar, but you need to download ldc2/dmd from official Digital Mars D website.
[dmd](https://downloads.dlang.org/releases/2.x/2.108.1/dmd-2.108.1.exe),
[ldc2](https://github.com/ldc-developers/ldc/releases/download/v1.38.0/ldc2-1.38.0-windows-multilib.exe)
and in powershell/cmd run commands as on Linux.

### API
its placed here:
[api](docs/api.md)

### Plans

Game will be open-source, and if will be developed fully will cost $1 at Steam(100RUB in VK Play).