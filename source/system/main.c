#include <stdbool.h>

#include "../../include/dialogbox.h"
#include "../../include/variables.h"
#include "../../include/abstraction.h"
#include "../../include/render_character.h"
#include "../../include/render_background.h"
#include "../../include/lua_bindings.h"
#include "../../include/audio.h"
#include "../../include/menus.h"

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
    bool menuDraw = false;
    SetTargetFPS(60);
    Font fontDialogBox = LoadFont(concat_strings(PREFIX, "res/font_en.png"));
    #ifdef _arch_dreamcast
    initAudioSystem();
    while (true) {
    #else
    while (!WindowShouldClose()) {
        UpdateMusicStream(BGM);
    #endif
        if (luaReload == true) {
            luaInit();
        }
        if (IsGamepadButtonPressed(0, GAMEPAD_BUTTON_RIGHT_FACE_UP)) {
            if (menuDraw == false) {
                menuDraw = true;
            } else {
                menuDraw = false;
            }
        }
        luaEventLoop();
        BeginDrawing();
        ClearBackground(BLACK);
        if (drawBackground == true) {
            draw2Dbackground(drawnBackgroundIndex);
        }
        if (drawCharacter == true) {
            draw2Dcharacter();
        }
        if (showDialog == true) {
            displayDialog(pages, pagesLength, dialogAnswerPage, fontDialogBox, &showDialog, typingSpeed);
        }
        if (menuDraw == true) {
            gameMenu();
        }
        EndDrawing();
    }
}