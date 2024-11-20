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

void main() {
	if (isReleaseBuild()) {
		SetTraceLogLevel(8);
	} else {
		SetTraceLogLevel(0);
	}
	validateRaylibBinding();
	SetExitKey(KeyboardKey.KEY_NULL);
	int screenWidth = GetScreenWidth();
	int screenHeight = GetScreenHeight();
	engine_loader("made in heaven", screenWidth, screenHeight);
}