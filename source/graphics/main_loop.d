module graphics.main_loop;

import raylib;
import bindbc.lua;
import graphics.video_playback;
import std.stdio;
import std.math;
import std.file;
import std.string;
import std.conv;
import ui.flicker;
import ui.battle_ui;
import graphics.ui_drawing;
import graphics.scene;
import variables;
import std.random;
import std.datetime;
import std.typecons;
import script;
import dialogs.dialog_system;
import ui.navigator;
import scripts.lua_engine;
import graphics.cubes;
import graphics.map;
import std.array;
import ui.inventory;

// Constants
enum FontSize = 20;
enum FadeIncrement = 0.02f;
enum ScreenPadding = 10;
enum TextSpacing = 30;
enum FPS = 60;

// Function Declarations
nothrow void loadLocation(char* first, float size);
void drawDebugInfo(Vector3 cubePosition, GameState currentGameState, int playerHealth, float cameraAngle, 
                   int playerStepCounter, int encounterThreshold, bool inBattle);
void drawWeatherDateTime(string weather, string time, string date);
ControlConfig loadControlConfig();
void closeAudio();
void fadeEffect(float alpha, bool fadeIn);
void engine_loader(string window_name, int screenWidth, int screenHeight);

// Function Implementations
nothrow void loadLocation(char* first, float size) {
    model_location_path = first;
    modelLocationSize = size;
    if (!rel) { 
        try { 
            writeln("loading loc ", model_location_path); 
        } catch (Exception e) {} 
    }
}

void drawDebugInfo(Vector3 cubePosition, GameState currentGameState, int playerHealth, float cameraAngle, 
                   int playerStepCounter, int encounterThreshold, bool inBattle) {
    const string debugText = q{
    Player Position: %s
    
    Battle State: %s
    
    Player Health: %d
    
    Camera Angle: %.2f
    
    PlayerStepCounter: %d
    
    EncounterThreshold: %d
    
    Release/debug Build: %s
    
    SoundState: %s
    
    FriendlyZone: %s
}.format(cubePosition, inBattle ? "In Battle" : "Exploring", playerHealth, cameraAngle, 
        playerStepCounter, encounterThreshold, rel, isAudioEnabled(), friendlyZone);

    DrawText(debugText.toStringz, 10, 10, FontSize, Colors.BLACK);
    DrawFPS(GetScreenWidth() - 100, GetScreenHeight() - 50);
}

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

void closeAudio() {
    UnloadMusicStream(music);
    CloseAudioDevice();
}

void fadeEffect(float alpha, bool fadeIn) {
    if (rel) {
        while (fadeIn ? alpha < 2.0f : alpha > 0.0f) {
            alpha += fadeIn ? FadeIncrement : -FadeIncrement;
            BeginDrawing();
            ClearBackground(Colors.BLACK);
            DrawTextEx(GetFontDefault(), "powered by\n\n\nHeaven Engine", 
                Vector2(GetScreenWidth() / 2 - MeasureText("powered by\n\n\nHeaven Engine", 40) / 2, 
                GetScreenHeight() / 2), 40, 0, Fade(Colors.WHITE, alpha)
            );
            EndDrawing();
        }
    }
}

import raylib_lights;

void engine_loader(string window_name, int screenWidth, int screenHeight) {
    // Initialization
    
    bool isGamepadConnected = IsGamepadAvailable(0);
    Vector3 targetPosition = { 10.0f, 0.0f, 20.0f };
    SetExitKey(KeyboardKey.KEY_NULL);
    float fadeAlpha = 2.0f;
    uint seed = cast(uint)Clock.currTime().toUnixTime();
    auto rnd = Random(seed);
    auto rnd_sec = Random(seed);
    
    encounterThreshold = uniform(900, 3000, rnd);
    randomNumber = uniform(1, 3, rnd_sec);
    
    // Window and Audio Initialization
    InitWindow(screenWidth, screenHeight, cast(char*)window_name);
    ToggleFullscreen();
    SetTargetFPS(FPS);
    rel = isReleaseBuild();
    
    // Fade In and Out Effects
    fadeEffect(0.0f, true);
    fadeEffect(fadeAlpha, false);
    
    // Play Opening Video
    BeginDrawing();
    playVideo(cast(char*)(getcwd()~"/res/opening.mp4"));
    ClearBackground(Colors.BLACK);
    EndDrawing();
    
    // Load Control Configuration and Initialize Audio
    immutable ControlConfig controlConfig = loadControlConfig();
    InitAudioDevice();
    showMainMenu(currentGameState);
    // Lua Initialization
    if (!rel) { writeln("loading lua"); }
    L = luaL_newstate();
    luaL_openlibs(L);
    luaL_registerAllLibraries(L);
    // Load Lua Script
    if (!rel) {
        if (luaL_dofile(L, "scripts/00_script.lua") != LUA_OK) {
            lua_pop(L, 1);
            writeln("Lua error: ", lua_tostring(L, -1));
        }
    } else {
        if (luaL_dofile(L, "scripts/event_00.bin") != LUA_OK) {
            lua_pop(L, 1);
            writeln("Script execution error: ", lua_tostring(L, -1));
        }
    }
    initWindowAndCamera(camera);
    // Load Models
    float cameraSpeed = 5.0f;
    float rotationStep = 1.3f;
    float radius = Vector3Distance(camera.position, camera.target);
    BoundingBox cubeBoundingBox;
    
    // Load Floor Model and Shaders
    Model floorModel = LoadModel(model_location_path);
    auto fs = "lighting.fs";
    auto vs = "lighting.vs";
    uint fssize;
    char *fsdata = get_file_data_from_archive("res/shaders.bin", cast(char*)fs, &fssize);
    uint vssize;
    char *vsdata = get_file_data_from_archive("res/shaders.bin", cast(char*)vs, &vssize);
    
    shader = LoadShaderFromMemory(vsdata, fsdata);
    
    // Set Shader Locations
    shader.locs[ShaderLocationIndex.SHADER_LOC_MATRIX_MODEL] = GetShaderLocation(shader, "matModel");
    shader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW] = GetShaderLocation(shader, "viewPos");
    int ambientLoc = GetShaderLocation(shader, "ambient");
    float[4] values = [ 0.1f, 0.1f, 0.1f, 1.0f ];
    SetShaderValue(shader, ambientLoc, &values[0], ShaderUniformDataType.SHADER_UNIFORM_VEC4);
    
    // Assign Shader to Models
    void assignShaderToModel(Model model) {
        for (int i = 0; i < model.materialCount; i++) {
            model.materials[i].shader = shader;
        }
    }
    
    assignShaderToModel(playerModel);
    foreach (ref cubeModel; cubeModels) {
        assignShaderToModel(cubeModel);
    }
    assignShaderToModel(floorModel);
    fontdialog = LoadFont("res/font_en.png");
    // Lighting Setup
    modelCharacterSize = 5.0f;
    lights[0] = CreateLight(LightType.LIGHT_POINT, Vector3(0, 9, 0), Vector3Zero(), Colors.LIGHTGRAY, shader);
    luaL_initDialogs(L);

    // Gamepad Mappings
    SetGamepadMappings("030000005e040000ea020000050d0000,Xbox Controller,a:b0,b:b1,x:b2,y:b3,back:b6,guide:b8,start:b7,leftstick:b9,rightstick:b10,leftshoulder:b4,rightshoulder:b5,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,    dpright:h0.2;
        030000004c050000c405000011010000,PS4 Controller,a:b1,b:b2,x:b0,y:b3,back:b8,guide:b12,start:b9,leftstick:b10,rightstick:b11,leftshoulder:b4,rightshoulder:b5,dpup:b11,dpdown:b14,dpleft:b7,dpright:b15,leftx:a0,lefty:a1,rightx:a2,righty:a5,lefttrigger:a3,righttrigger:a4;");
    foreach (i, cubeModel; cubeModels) {
        cubes[i].rotation = 0.0f;
    }
    // Main Game Loop
    while (!WindowShouldClose()) {
        if (videoFinished) {
            switch (currentGameState) {
                case GameState.MainMenu:
                    showMainMenu(currentGameState);
                    break;

                case GameState.InGame:
                    deltaTime = GetFrameTime();
                    if (isAudioEnabled()) {
                        UpdateMusicStream(music);
                    }
                    UpdateLightValues(shader, lights[0]);    
                    luaL_updateDialog(L);
                    
                    // Update camera and player positions
                    updateCameraAndCubePosition(camera, cubePosition, cameraSpeed, deltaTime,
                        controlConfig.forward_button,
                        controlConfig.back_button, controlConfig.left_button, controlConfig.right_button, allowControl);
                    rotateCamera(camera, cubePosition, cameraAngle, rotationStep, radius);

                    Nullable!Cube collidedCube = handleCollisions(cubePosition, cubes, cubeBoundingBox);
                    BeginDrawing();
                    ClearBackground(Colors.RAYWHITE);
                    
                    if (!isNaN(iShowSpeed) && !isNaN(neededDegree) && !isNewLocationNeeded) {
                        rotateScriptCamera(camera, cubePosition, cameraAngle, neededDegree, iShowSpeed, radius, deltaTime);
                    }

                    if (isNewLocationNeeded) {
                        playerStepCounter = 0;
                        cubePosition = Vector3(0, 0, 0);
                        camera.position = Vector3(0, 10, 10);
                        camera.target = Vector3(0, 4, 0);
                        cameraAngle = 90.0f;
                        UnloadModel(floorModel);
                        floorModel = LoadModel(model_location_path);
                        isNewLocationNeeded = false;
                        assignShaderToModel(floorModel);
                    }

                    drawScene(floorModel, camera, cubePosition, cameraAngle, cubeModels, playerModel);
                    
                    if (show_sec_dialog && showDialog) {
                        allow_exit_dialog = allowControl = false;
                        display_dialog(name_global, emotion_global, message_global, pageChoice_glob);
                    } else {
                        displayDialogs(collidedCube, controlConfig.dialog_button, allowControl, showDialog, 
                        allow_exit_dialog, name);
                    }

                    float colorIntensity = !friendlyZone && playerStepCounter < encounterThreshold ?
                        1.0f - (cast(float)(encounterThreshold - playerStepCounter) / encounterThreshold) : 0.0f;

                    if (!friendlyZone && playerStepCounter >= encounterThreshold && !inBattle) {
                        originalCubePosition = cubePosition;
                        originalCameraPosition = camera.position;
                        originalCameraTarget = camera.target;
                        StopMusicStream(music);
                        allowControl = false;
                        playerStepCounter = 0;
                        encounterThreshold = uniform(900, 3000, rnd);
                        inBattle = true;
                        initBattle(camera, cubePosition, cameraAngle, randomNumber, false);
                    }

                    if (inBattle) {
                        cameraAngle = 90.0f;
                        drawBattleUI(camera, cubePosition);
                        UpdateMusicStream(musicBattle);
                        if (!selectingEnemy) {
                            drawHPAboveCubes(camera);
                        }
                    } else {
                        PlayMusicStream(music);
                    }

                    // Show Map Prompt
                    showMapPrompt = Vector3Distance(cubePosition, targetPosition) < 4.0f;

                    if (showMapPrompt) {
                        const int posY = GetScreenHeight() - FontSize - 40;
                        if (isGamepadConnected) {
                            const int buttonSize = 30;
                            const int circleCenterX = 40 + buttonSize / 2;
                            const int circleCenterY = posY + buttonSize / 2;
                            const int textYOffset = 7;
                            DrawCircle(circleCenterX, circleCenterY, buttonSize / 2, Colors.GREEN);
                            DrawText(("A"), circleCenterX - 5, circleCenterY - textYOffset, 20, Colors.BLACK);
                            DrawText((" to open map"), 40 + buttonSize + 5, posY, 20, Colors.BLACK);
                        } else {
                            DrawText(toStringz("Press "~(controlConfig.dialog_button)~" to open map"), 40, posY, 20, Colors.BLACK);
                        }

                        if (IsKeyPressed(controlConfig.dialog_button) || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) {
                            StopMusicStream(music);
                            openMap(location_name);
                        }
                    }
                    if (showDialog) {

                    } else {
                        // Flickering Effect
                        int colorChoice = colorIntensity > 0.75 ? 3 : colorIntensity > 0.5 ? 2 : colorIntensity > 0.25 ? 1 : 0;
                        if (!inBattle && !friendlyZone) {
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
                    if (IsKeyPressed(KeyboardKey.KEY_F3) && currentGameState == GameState.InGame && !rel) {
                        showDebug = !showDebug;
                    }
                    // Check Dialog Status
                    lua_getglobal(L, "checkDialogStatus");
                    if (lua_pcall(L, 0, 2, 0) == LUA_OK) {
                        lua_pop(L, 2);
                    } else {
                        writeln("Unable to check dialog status or cannot rotate camera: ", to!string(lua_tostring(L, -1)));
                        lua_pop(L, 1);
                    }

                    // Draw Debug Information
                    if (showDebug) {
                        drawDebugInfo(cubePosition, currentGameState, playerHealth, cameraAngle, playerStepCounter, 
                        encounterThreshold, inBattle);
                    }

                    // Inventory Handling
                    if (IsKeyPressed(controlConfig.opmenu_button)) {
                        showInventory = true;
                    }
                    if (showInventory) {
                        drawInventory();
                    }
                    EndDrawing();
                    break;

                case GameState.Options:
                    // Handle options menu here
                    break;

                case GameState.Exit:
                    StopMusicStream(music);
                    EndDrawing();
                    CloseWindow();
                    closeAudio();
                    lua_close(L);
                    return;

                default:
                    break;
            }
        }
    }

    // Cleanup
    EndDrawing();
    UnloadShader(shader); 
    scope(exit) closeAudio();
    scope(exit) CloseWindow();
    lua_close(L);
}