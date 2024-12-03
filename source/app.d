//quantumde1 developed software, licensed under BSD-0-Clause license.
import raylib;

import std.stdio;
//local imports
import graphics.main_loop;
import graphics.video_playback;
import variables;
import std.file;
import std.string;
import script;

void main(string[] args) {
    if (isReleaseBuild()) {
        SetTraceLogLevel(8);
    } else {
        SetTraceLogLevel(0);
    }
    validateRaylibBinding();
    SetExitKey(KeyboardKey.KEY_NULL);
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    
    // Check if there are enough arguments
    if (args.length > 1) {
        engine_loader("made in heaven", screenWidth, screenHeight, args[1]);    
    } else {
        engine_loader("made in heaven", screenWidth, screenHeight, "scripts/00_script.lua");
    }
}