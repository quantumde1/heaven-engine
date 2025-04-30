// quantumde1 developed software, licensed under MIT license.
import raylib;

import std.stdio;
//local imports
import graphics.engine;
import graphics.video;
import variables;
import std.file;
import std.string;
import scripts.config;
import std.conv;


void main(string[] args) {
    if (isReleaseBuild()) {
        SetTraceLogLevel(7);
    } else {
        SetTraceLogLevel(0);
    }
    validateRaylibBinding();
    SetExitKey(0);
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    // Check if there are enough arguments
    lua_exec = "scripts/00_script.lua";
    if (args.length > 2) {
        lua_exec = getcwd().to!string~"/"~args[1];
        engine_loader("made in heaven", screenWidth, screenHeight, args[2].to!bool);    
    } else {
        engine_loader("made in heaven", screenWidth, screenHeight, false);
    }
}