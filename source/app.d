// quantumde1 developed software, licensed under MIT license.
import raylib;

import std.stdio;

//local imports
import graphics.engine;
import graphics.playback;
import variables;
import std.file;
import std.string;
import scripts.config;
import std.conv;

void main(string[] args)
{
    validateRaylibBinding();
    debug {
        SetTraceLogLevel(0);
    } else {
        SetTraceLogLevel(7);
    }
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    luaExec = "scripts/00_script.lua";
    if (args.length > 2)
    {
        luaExec = getcwd().to!string ~ "/" ~ args[1];
        engine_loader("made in heaven", screenWidth, screenHeight, args[2].to!bool);
    }
    else
    {
        engine_loader("made in heaven", screenWidth, screenHeight, false);
    }
}