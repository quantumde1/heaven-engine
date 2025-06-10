#include <stdbool.h>

#include "../../include/dialogbox.h"
#include "../../include/variables.h"
#include "../../include/abstraction.h"
#include "../../include/render_character.h"
#include "../../include/render_background.h"
#include "../../include/lua_bindings.h"
#include "../../include/audio.h"

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
    Font fontDialogBox = LoadFont(concat_strings(PREFIX, "res/font_en.png"));
    load2Dbackground("res/backgrounds/out.png", 0);
    luaInit(concat_strings(PREFIX, "scripts/00_script.lua"));
    #ifdef _arch_dreamcast
    while (true) {
        initAudioSystem();
    #else
    while (!WindowShouldClose()) {
        UpdateMusicStream(BGM);
    #endif
        BeginDrawing();
        ClearBackground(WHITE);
        luaEventLoop();
        if (drawBackground == true) {
            draw2Dbackground(drawnBackgroundIndex);
        }
        if (drawCharacter == true) {
            draw2Dcharacter();
        }
        if (showDialog == true) {
            displayDialog(pages, pagesLength, -1, fontDialogBox, &showDialog, typingSpeed);
        }
        EndDrawing();
    }
    #ifdef _arch_dreamcast
    shutdownAudioSystem();
    #endif
}