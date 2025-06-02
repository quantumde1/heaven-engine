// quantumde1 developed software, licensed under MIT license.
module graphics.engine;

import raylib;
import graphics.playback;
import std.stdio;
import std.math;
import std.file;
import graphics.gamelogic;
import std.string;
import std.conv;
import variables;
import std.random;
import std.datetime;
import ui.menu;
import std.typecons;
import scripts.config;
import dialogs.dialogbox;
import scripts.lua;
import std.array;

ControlConfig loadControlConfig()
{
    return ControlConfig(
        parse_conf("conf/layout.conf", "right"),
        parse_conf("conf/layout.conf", "left"),
        parse_conf("conf/layout.conf", "backward"),
        parse_conf("conf/layout.conf", "forward"),
        parse_conf("conf/layout.conf", "dialog"),
        parse_conf("conf/layout.conf", "opmenu")
    );
}

void unloadResourcesLogic()
{
    debug_writeln("Exiting. See ya'!");
    StopMusicStream(music);
    EndDrawing();
    if (sfxEnabled) {
        UnloadSound(audio.menuMoveSound);
        UnloadSound(audio.acceptSound);
        UnloadSound(audio.menuChangeSound);
        UnloadSound(audio.declineSound);
        UnloadSound(audio.nonSound);
    }
    UnloadFont(textFont);
    for (int i = cast(int) characterTextures.length; i < characterTextures.length; i++)
    {
        UnloadTexture(characterTextures[i].texture);
    }
    for (int i = cast(int) backgrounds.length; i < backgrounds.length; i++)
    {
        UnloadTexture(backgrounds[i]);
    }
    UnloadMusicStream(music);
    CloseAudioDevice();
    CloseWindow();
}

void engine_loader(string window_name, int screenWidth, int screenHeight, bool play)
{
    // Initialization
    debug debug_writeln("Engine version: ", ver);
    SetExitKey(0);
    // Window and Audio Initialization
    InitWindow(screenWidth, screenHeight, cast(char*) window_name);
    DisableCursor();
    ToggleFullscreen();
    SetTargetFPS(60);
    textFont = LoadFont("res/font_en.png");
    // Fade In and Out Effects
    InitAudioDevice();
    audioEnabled = isAudioEnabled();
    debug debug_writeln("hello screen showing");
    debug
    {
        if (play == false)
        {
            videoFinished = true;
            goto debug_lab;
        }
    }
    else
    {
        helloScreen();
    }
debug_lab:
    //videoFinished = true;
    ClearBackground(Colors.BLACK);
    EndDrawing();
    while (true)
    {
        switch (currentGameState)
        {
        case GameState.MainMenu:
            debug_writeln("Showing menu.");
            showMainMenu(currentGameState);
            break;
        case GameState.InGame:
            import core.stdc.stdlib;
            import core.stdc.time;

            gameInit();
            while (!WindowShouldClose())
            {
                SetExitKey(0);
                if (luaReload)
                {
                    luaInit(luaExec);
                    luaReload = false;
                }
                luaEventLoop();
                BeginDrawing();
                ClearBackground(Colors.BLACK);
                //all drawing must be here
                /* visual novel element block */
                vnLogic();

                EndDrawing();
            }
            break;
        case GameState.Exit:
            EndDrawing();
            unloadResourcesLogic();
            return;

        default:
            break;
        }
    }
}