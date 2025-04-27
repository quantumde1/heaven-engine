// quantumde1 developed software, licensed under BSD-0-Clause license.
module graphics.engine;

import raylib;
import graphics.video;
import std.stdio;
import std.math;
import std.file;
import graphics.gamelogic;
import std.string;
import std.conv;
import ui.flicker;
import graphics.battle;
import ui.menu;
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

ControlConfig loadControlConfig() {
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
enum FadeIncrement = 0.02f;
enum ScreenPadding = 10;
enum TextSpacing = 30;

debug {
    void drawDebugInfo(Vector3 cubePosition, GameState currentGameState, int playerHealth, float cameraAngle, 
                    int playerStepCounter, int encounterThreshold, bool inBattle) {
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
            playerStepCounter, encounterThreshold,  audioEnabled, friendlyZone, camera.position, camera.target, shaderEnabled, musicpath.to!string, audioEnabled, randomNumber+1, XP, stamina);
        if (currentGameState == GameState.MainMenu) { DrawText(debugText.toStringz, 10, 10, 20, Colors.WHITE);}
        else {DrawText(debugText.toStringz, 10, 10, 20, Colors.BLACK);}
        DrawFPS(GetScreenWidth() - 100, GetScreenHeight() - 50);
    }
}

void closeAudio() {
    UnloadMusicStream(music);
    CloseAudioDevice();
}

void fadeEffect(float alpha, bool fadeIn, immutable(char*) text) {
    while (fadeIn ? alpha < 2.0f : alpha > 0.0f) {
        alpha += fadeIn ? FadeIncrement : -FadeIncrement;
        BeginDrawing();
        ClearBackground(Colors.BLACK);
        DrawTextEx(fontdialog, text, 
            Vector2(GetScreenWidth() / 2 - MeasureText(text, 40) / 2, 
            GetScreenHeight() / 2), 40, 0, Fade(Colors.WHITE, alpha)
        );
        EndDrawing();
    }
}

void fadeEffectLogo(float alpha, bool fadeIn, immutable(char*) name, bool fullscreen) {
    while (fadeIn ? alpha < 2.0f : alpha > 0.0f) {
        alpha += fadeIn ? FadeIncrement : -FadeIncrement;
        uint image_size;
        char *image_data_logo = get_file_data_from_archive("res/data.bin", name, &image_size);
        Texture2D atlus = LoadTextureFromImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data_logo, image_size));
        UnloadImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data_logo, image_size));
        BeginDrawing();
        ClearBackground(Colors.BLACK);
        if (fullscreen) DrawTexturePro(atlus, Rectangle(0, 0, cast(float)atlus.width, cast(float)atlus.height), Rectangle(0, 0, cast(float)GetScreenWidth(), cast(float)GetScreenHeight()), Vector2(0, 0), 0.0, Fade(Colors.WHITE, alpha));
        if (!fullscreen) DrawTexture(atlus, GetScreenWidth()/2, GetScreenHeight()/2, Colors.WHITE);
        EndDrawing();
    }
}

void helloScreen() {
    float fadeAlpha = 2.0f;
    fadeEffect(0.0f, true, "powered by\n\nHeaven Engine");
    fadeEffect(fadeAlpha, false, "powered by\n\nHeaven Engine");
    //fadeEffectLogo(0.0f, true, "atlus_logo.png".toStringz, true);
    //fadeEffectLogo(fadeAlpha, false, "atlus_logo.png".toStringz, true);
    fadeEffect(0.0f, true, "under\nlevel\nprod.\n\npresents");
    fadeEffect(fadeAlpha, false, "under\nlevel\nprod.\n\npresents");
    // Play Opening Video
    BeginDrawing();
    debug debug_writeln("searching for video");
    if (std.file.exists(getcwd()~"/res/videos/soul_OP.moflex.mp4")) {
        debug debug_writeln("video found, playing");
        version (Windows) {
            playVideo(cast(char*)("/"~getcwd()~"/res/videos/soul_OP.moflex.mp4"));
        }
        version (Posix) {
            playVideo(cast(char*)(getcwd()~"/res/videos/soul_OP.moflex.mp4"));
        }
    } else {
        videoFinished = true;
    }
}

void engine_loader(string window_name, int screenWidth, int screenHeight, string lua_exec, bool play) {
    // Initialization
    gamepadInt = 0;
    version (linux) {
        gamepadInt = 1;
        debug debug_writeln("Linux version detected");
    }
    version (Windows) {
        debug debug_writeln("Windows version detected");
    }
    version (osx) {
        debug debug_writeln("macOS version detected");
    }
    debug debug_writeln("Engine version: ", ver);
    SetExitKey(0);
    // Window and Audio Initialization
    InitWindow(screenWidth, screenHeight, cast(char*)window_name);
    DisableCursor();
    ToggleFullscreen();
    Font navFont = LoadFont("res/font_16x16_en.png");
    SetTargetFPS(FPS);
    fontdialog = LoadFont("res/font_en.png");
    // Fade In and Out Effects
    InitAudioDevice();
    audioEnabled = isAudioEnabled();
    debug debug_writeln("hello screen showing");
    debug {
        if (play == false) { videoFinished = true; goto debug_lab; }
    }
    else {
        helloScreen();
    }
    debug_lab:
    //videoFinished = true;
    ClearBackground(Colors.BLACK);
    EndDrawing();
    // Gamepad Mappings
    SetGamepadMappings("030000005e040000ea020000050d0000,Xbox Controller,a:b0,b:b1,x:b2,y:b3,back:b6,guide:b8,start:b7,leftstick:b9,rightstick:b10,leftshoulder:b4,rightshoulder:b5,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,    dpright:h0.2;
        030000004c050000c405000011010000,PS4 Controller,a:b1,b:b2,x:b0,y:b3,back:b8,guide:b12,start:b9,leftstick:b10,rightstick:b11,leftshoulder:b4,rightshoulder:b5,dpup:b11,dpdown:b14,dpleft:b7,dpright:b15,leftx:a0,lefty:a1,rightx:a2,righty:a5,lefttrigger:a3,righttrigger:a4;");
    foreach (i, cubeModel; cubeModels) {
        cubes[i].rotation = 0.0f;
    }
    while (true) {
    switch (currentGameState) {
    case GameState.MainMenu:
        debug_writeln("Showing menu.");
        showMainMenu(currentGameState);
        break;
    case GameState.InGame:
        import core.stdc.stdlib;
        import core.stdc.time;
        srand(cast(uint)time(null));
        gameInit();
        luaInit(lua_exec);          
        float cameraSpeed = 5.0f;
        // Load gltf model animations
        int animsCount = 0;
        int animCurrentFrame = 0;
        ModelAnimation* modelAnimations = LoadModelAnimations(playerModelName, &animsCount);
        float fov = 45.0f;
        while (!WindowShouldClose()) {
            SetExitKey(0);
            luaEventLoop();
                cameraLogic(camera, fov);
                shadersLogic();
                deltaTime = GetFrameTime();
                if (audioEnabled) {
                    UpdateMusicStream(music);
                }
                // Update camera and player positions
                updatePlayerOBB(playerOBB, cubePosition, modelCharacterSize, playerModelRotation);
                controlFunction(camera, cubePosition, controlConfig.forward_button, controlConfig.back_button, controlConfig.left_button, controlConfig.right_button, allowControl, deltaTime, cameraSpeed);
                rotateCamera(camera, cubePosition, cameraAngle, rotationStep, radius);
                BeginDrawing();
                ClearBackground(Colors.BLACK);
                if (neededDraw2D) {
                    allowControl = false;
                    DrawTexturePro(texture_background, Rectangle(0, 0, cast(float)texture_background.width, cast(float)texture_background.height), Rectangle(0, 0, cast(float)GetScreenWidth(), cast(float)GetScreenHeight()), Vector2(0, 0), 0.0, Colors.WHITE);
                }
                if (neededCharacterDrawing) {
                    allowControl = false;
                    for (int i = 0; i < tex2d.length; i++) {
                        DrawTextureEx(tex2d[i].texture, Vector2(tex2d[i].x, tex2d[i].y), 0.0, tex2d[i].scale, Colors.WHITE);
                    }
                }
                if (!neededDraw2D && !inBattle) {
                    DrawTexturePro(texture_skybox, Rectangle(0, 0, cast(float)texture_skybox.width, cast(float)texture_skybox.height), Rectangle(0, 0, cast(float)GetScreenWidth(), cast(float)GetScreenHeight()), Vector2(0, 0), 0.0, Colors.WHITE);
                    drawScene(floorModel, camera, cubePosition, cameraAngle, cubeModels, playerModel);
                }
                if (animations == 1) {
                    animationsLogic(currentFrame, animCurrentFrame, modelAnimations, collisionDetected);
                }
                if (!isNaN(iShowSpeed) && !isNaN(neededDegree)) {
                    rotateScriptCamera(camera, cubePosition, cameraAngle, neededDegree, iShowSpeed, radius, deltaTime);
                }
                if (!inBattle && !showInventory && !showDialog && !hideNavigation) {
                    draw_navigation(cameraAngle, navFont, fontdialog);
                }
                float colorIntensity = !friendlyZone && playerStepCounter < encounterThreshold ?
                    1.0f - (cast(float)(encounterThreshold - playerStepCounter) / encounterThreshold) : 0.0f;
                
                debug {
                    if (IsKeyPressed(KeyboardKey.KEY_F4)) {
                        playerStepCounter = encounterThreshold + 1;
                    }
                }
                battleLogic();
                showHintLogic();
                if (show_sec_dialog && showDialog) {
                    allow_exit_dialog = allowControl = false;
                    display_dialog(name_global, emotion_global, message_global, pageChoice_glob);
                }
                if (!showDialog) {
                    // Flickering Effect
                    int colorChoice = colorIntensity > 0.75 ? 3 : colorIntensity > 0.5 ? 2 : colorIntensity > 0.25 ? 1 : 0;
                    if (!inBattle && !friendlyZone && !hideNavigation) {
                        draw_flickering_rhombus(colorChoice, colorIntensity);
                    }
                }
                // Update Moving Cubes
                foreach (ref cube; cubes) {
                    if (cube.isMoving) {
                        float elapsedTime = GetTime() - cube.moveStartTime;
                        if (elapsedTime >= cube.moveDuration) {
                            cube.boundingBox.min = cube.endPosition;
                            cube.isMoving = false;
                            beginNextMove(cube);
                        } else {
                            float t = elapsedTime / cube.moveDuration;
                            cube.boundingBox.min = Vector3Lerp(cube.startPosition, cube.endPosition, t);
                            cube.boundingBox.max = Vector3Add(cube.boundingBox.min, Vector3(2.0f, 2.0f, 2.0f));
                        }
                    }
                }

                // Debug Toggle
                debug {
                    if (IsKeyPressed(KeyboardKey.KEY_F3) && currentGameState == GameState.InGame) {
                        showDebug = !showDebug;    
                    }
                }
                // Draw Debug Information
                if (showDebug) {
                    debug {
                        drawDebugInfo(cubePosition, currentGameState, partyMembers[0].currentHealth, cameraAngle, playerStepCounter, 
                        encounterThreshold, inBattle);
                    }
                }

                // Inventory Handling
                if (IsKeyPressed(controlConfig.opmenu_button) && !showDialog || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_UP) && !showDialog) {
                    showInventory = true;
                }
                if (showInventory) {
                    drawInventory();
                }
                EndDrawing();
                }
                break;
            case GameState.Exit:
                debug_writeln("Exiting. See ya'!");
                StopMusicStream(music);
                EndDrawing();
                CloseWindow();
                UnloadFont(fontdialog);
                for (int i = cast(int)tex2d.length; i < tex2d.length; i++) {
                    UnloadTexture(tex2d[i].texture);
                }
                for (int i = cast(int)backgrounds.length; i < backgrounds.length; i++) {
                    UnloadTexture(backgrounds[i]);
                }
                closeAudio();
                return;

            default:
                break;
        }
    }
    // Cleanup
    EndDrawing();
    UnloadShader(shader); 
    scope(exit) closeAudio();
    scope(exit) CloseWindow();
}