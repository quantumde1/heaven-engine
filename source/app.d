//quantumde1 developed software, licensed under BSD-0-Clause license.
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
    SetExitKey(KeyboardKey.KEY_NULL);
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    // Check if there are enough arguments
    if (args.length > 2) {
        engine_loader("made in heaven", screenWidth, screenHeight, getcwd().to!string~"/"~args[1], args[2].to!bool);    
    } else {
        engine_loader("made in heaven", screenWidth, screenHeight, "scripts/00_script.lua", false);
    }
}