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
import ui.flicker;
import graphics.battle;
import ui.menu;
import ui.common;
import graphics.scene;
import variables;
import std.random;
import std.datetime;
import std.typecons;
import scripts.config;
import dialogs.dialog_system;
import ui.navigator;
import scripts.lua;
import graphics.cubes;
import raylib_lights;
import graphics.map;
import graphics.collision;
import std.array;
import ui.inventory;

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

// Constants
enum FontSize = 20;
enum ScreenPadding = 10;
enum TextSpacing = 30;
const float cameraSpeed = 5.0f;

debug
{
    void drawDebugInfo(Vector3 cubePosition, GameState currentGameState, int playerHealth, float cameraAngle,
        int playerStepCounter, int encounterThreshold, bool inBattle)
    {
        const string debugText = q{
    Player Position: %s
    
    Battle State: %s
    
    Player Health: %d
    
    Camera Angle: %.2f
    
    PlayerStepCounter: %d
    
    EncounterThreshold: %d
    
    SoundState: %s
    
    FriendlyZone: %s

    Camera Position: %s

    Camera Target: %s

    Shaders: %s

    Music file: %s

    Music State: %s

    Random encounter enemy count: %d

    player XP: %d

    Stamina: %f
    }.format(cubePosition, inBattle ? "battle" : "non battle", playerHealth, cameraAngle,
            playerStepCounter, encounterThreshold, audioEnabled, friendlyZone, camera.position, camera.target, shaderEnabled, musicpath
                .to!string, audioEnabled, randomNumber + 1, XP, stamina);
        if (currentGameState == GameState.MainMenu)
        {
            DrawText(debugText.toStringz, 10, 10, 20, Colors.WHITE);
        }
        else
        {
            DrawText(debugText.toStringz, 10, 10, 20, Colors.BLACK);
        }
        DrawFPS(GetScreenWidth() - 100, GetScreenHeight() - 50);
    }
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
    UnloadFont(fontdialog);
    for (int i = cast(int) tex2d.length; i < tex2d.length; i++)
    {
        UnloadTexture(tex2d[i].texture);
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
    gamepadInt = 0;
    debug debug_writeln("Engine version: ", ver);
    SetExitKey(0);
    // Window and Audio Initialization
    InitWindow(screenWidth, screenHeight, cast(char*) window_name);
    DisableCursor();
    ToggleFullscreen();
    Font navFont = LoadFont("res/font_16x16_en.png");
    SetTargetFPS(FPS);
    fontdialog = LoadFont("res/font_en.png");
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
    // Gamepad Mappings
    SetGamepadMappings("030000005e040000ea020000050d0000,Xbox Controller,a:b0,b:b1,x:b2,y:b3,back:b6,guide:b8,start:b7,leftstick:b9,rightstick:b10,leftshoulder:b4,rightshoulder:b5,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,    dpright:h0.2;
        030000004c050000c405000011010000,PS4 Controller,a:b1,b:b2,x:b0,y:b3,back:b8,guide:b12,start:b9,leftstick:b10,rightstick:b11,leftshoulder:b4,rightshoulder:b5,dpup:b11,dpdown:b14,dpleft:b7,dpright:b15,leftx:a0,lefty:a1,rightx:a2,righty:a5,lefttrigger:a3,righttrigger:a4;");
    foreach (i, cubeModel; cubeModels)
    {
        cubes[i].rotation = 0.0f;
    }
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

            srand(cast(uint) time(null));
            gameInit();
            // Load gltf model animations
            int animsCount = 0;
            int animCurrentFrame = 0;
            float fov = 45.0f;
            defaultCamera = camera;
            while (!WindowShouldClose())
            {
                SetExitKey(0);
                if (luaReload)
                {
                    luaInit(lua_exec);
                    if (animations == 1)
                        modelAnimations = LoadModelAnimations(playerModelName, &animsCount);
                    luaReload = false;
                }
                if (!showInventory)
                {
                    if (audioEnabled)
                    {
                        UpdateMusicStream(music);
                    }
                    deltaTime = GetFrameTime();
                    luaEventLoop();
                    shadersLogic();
                    playerLogic(cameraSpeed);
                    BeginDrawing();
                    ClearBackground(Colors.BLACK);
                    cameraLogic(camera, fov);
                    animationsLogic(animCurrentFrame, modelAnimations, collisionDetected);
                    //all drawing must be here

                    /* visual novel element block */
                    vnLogic();

                    showHintLogic();
                    navigationDrawLogic(navFont);
                }
                /* battle block(not theather btw) */
                battleInitLogic();
                battleLogic();

                // Inventory Handling
                inventoryLogic();
                // Debug Toggle
                debugLogic();
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