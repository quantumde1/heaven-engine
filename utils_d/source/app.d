import raylib;
import std.math;
import std.conv;
import std.string;
import raygui;
import std.stdio;

void main(string[] args) {
    SetConfigFlags(ConfigFlags.FLAG_WINDOW_MAXIMIZED);
    SetConfigFlags(ConfigFlags.FLAG_WINDOW_RESIZABLE);
    InitWindow(800, 600, "test raygui");
	SetTargetFPS(30);
    while (WindowShouldClose() == false) {
		BeginDrawing();
		ClearBackground(Colors.RAYWHITE);
        GuiButton(Rectangle(100, 100, 300, 50), toStringz("Testing"));
        EndDrawing();
    }
    CloseWindow();
}