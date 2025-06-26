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
import system.abstraction;
import system.config;
import dialogs.dialogbox;
import scripts.lua;
import std.array;
import system.abstraction;
import system.cleanup;

void engine_loader(string window_name, int screenWidth, int screenHeight)
{
    // Initialization
    debug debugWriteln("Engine version: ", ver);
    SetExitKey(0);
    // Window and Audio Initialization
    InitWindow(screenWidth, screenHeight, cast(char*) window_name);
    DisableCursor();
    ToggleFullscreen();
    SetTargetFPS(60);
    textFont = LoadFont("res/font_en.png");
    // Fade In and Out Effects
    InitAudioDevice();
    audioEnabled = systemSettings.sound_state.to!bool;
    helloScreen();
    ClearBackground(Colors.BLACK);
    EndDrawing();
    camera.target = Vector2(screenWidth/2.0f, screenHeight/2.0f);
    camera.offset = Vector2(screenWidth/2.0f, screenHeight/2.0f);
    camera.rotation = 0.0f;
    camera.zoom = 1.0f;
    while (true)
    {
        switch (currentGameState)
        {
        case GameState.MainMenu:
            debugWriteln("Showing menu.");
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
                    int luaExecutionCode = luaInit(luaExec);
                    if (luaExecutionCode != EngineExitCodes.EXIT_OK) {
                        debugWriteln("Engine stops execution according to error code: ", luaExecutionCode);
                        currentGameState = GameState.Exit;
                        break;
                    }
                    luaReload = false;
                }
                luaEventLoop();
                BeginDrawing();
                ClearBackground(Colors.BLACK);
                // main logic
                // effects logic
                BeginMode2D(camera);
                backgroundLogic();
                effectsLogic();
                EndMode2D();
                dialogLogic();
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