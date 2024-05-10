import raylib;

import std.stdio;
//local imports
import graphics.main_cycle;

void main() {
	validateRaylibBinding();
	int screenWidth = GetScreenWidth();
	int screenHeight = GetScreenHeight();
	engine_loader("made in heaven", screenWidth, screenHeight);
	scope(exit) CloseWindow();
}