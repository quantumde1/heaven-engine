import raylib;

import std.stdio;
//local imports
import engine_part;

void main() {
	int screenWidth = GetScreenWidth();
	int screenHeight = GetScreenHeight();
	engine_loader("made in heaven", screenWidth, screenHeight);
}