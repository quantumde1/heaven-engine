#include <stdbool.h>

#include "../../include/dialogbox.h"
#include "../../include/variables.h"
#include "../../include/abstraction.h"
#include "../../include/render_character.h"
#include "../../include/render_background.h"
#include "../../include/lua_bindings.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <raylib.h>

int main() {
    int screenWidth = 640;
    int screenHeight = 480;
    InitWindow(screenWidth, screenHeight, "dialogbox test in C");
    #ifndef _arch_dreamcast
    InitAudioDevice();
    #endif
    SetTargetFPS(60);
    Font fontDialogBox = LoadFont(concat_strings(PREFIX, "font_en.png"));
    int pagesCount = 1;
    load2Dbackground("backgrounds/out.png", 0);
    #ifdef _arch_dreamcast
    while (true) {
    #else
    while (!WindowShouldClose()) {
    #endif
        BeginDrawing();
        ClearBackground(WHITE);
        luaEventLoop();
        EndDrawing();
    }
}