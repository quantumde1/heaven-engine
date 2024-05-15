# Heaven engine(Meido in Hebun!)

Engine, developed primarly for Sky game series. Its now in state of active development, game too :)

## Features
Features, available now:
- [x] Simple source code with comments(based on raylib by @raysan5)
- [x] Lua scripts (only few functions implemented)
- [x] Control configuration file
- [x] Static build on Linux, for Windows must be used dynamic
- [x] Audio playing
- [ ] Battle system
- [ ] Main menu
- [ ] Pause menu
- [ ] Personas, skills, load, etc menus
- [ ] Loading models and sprites

## Simple docs!

### Building

For building, you need install this packages(at least on Alpine linux):

```apk add raylib-dev lua5.4-dev dub ldc alpine-sdk```

after this, in source directory, run for debug:

```dub build --force```

and for release

```dub build --build=release```

On windows, instructions is similar, but you need to download ldc2/dmd from official Digital Mars D website.

[dmd](https://downloads.dlang.org/releases/2.x/2.108.1/dmd-2.108.1.exe),
[ldc2](https://github.com/ldc-developers/ldc/releases/download/v1.38.0/ldc2-1.38.0-windows-multilib.exe)

and in powershell/cmd run commands as on Linux. !!!REMEMBER!!! windows build is ALWAYS dynamic. I will not complain about people who want static Windows build.

### Usage

You can modify ```scripts/00_script.lua``` for test. Available functions:

```addCube(coor_x, coor_y, coor_z, "name", {"text page 1", "text page two", "text page three"}, emotion)```
```startCubeMove(cube_number, coor_x, coor_y, coor_z, speed)```

coor_x, coor_y, coor_z and speed must be float, name is string, text on pages are string, and emotion is int(not yet implemented enum)

### Plans

Game will be open-source, and if will be developed fully will cost $1 at Steam(100RUB in VK Play).