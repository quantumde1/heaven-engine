import raylib;

import std.stdio;
//local imports
import engine_part;

void main(string[] args) {
	int screenWidth = GetScreenWidth();
	int screenHeight = GetScreenHeight();
	if (args.length <= 1) {
		writeln("set window name");
		return;
	}
	engine_loader(args[1], screenWidth, screenHeight);
}