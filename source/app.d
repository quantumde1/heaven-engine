// quantumde1 developed software, licensed under MIT license.
import raylib;

import std.stdio;

//local imports
import graphics.engine;
import graphics.playback;
import variables;
import std.file;
import std.string;
import system.abstraction;
import system.config;
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
    if (args.length > 1)
    {
        writeln("!!!If needed, there is first argument for choosing script to execute.!!!");
        luaExec = getcwd().to!string ~ "/" ~ args[1];
        engine_loader("tief blau", screenWidth, screenHeight);
    }
    else
    {
        engine_loader("tief blau", screenWidth, screenHeight);
    }
}