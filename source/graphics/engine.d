// quantumde1 developed software, licensed under BSD-0-Clause license.
module graphics.engine;

import raylib;
import bindbc.lua;
import graphics.video;
import std.stdio;
import std.math;
import std.file;
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

    Random encounter enemy count: %d

    player XP: %d

    Stamina: %f
}.format(cubePosition, inBattle ? "battle" : "non battle", playerHealth, cameraAngle, 
        playerStepCounter, encounterThreshold,  audioEnabled, friendlyZone, camera.position, camera.target, shaderEnabled, musicpath.to!string, randomNumber+1, XP, stamina);
    if (currentGameState == GameState.MainMenu) { DrawText(debugText.toStringz, 10, 10, 20, Colors.WHITE);}
    else {DrawText(debugText.toStringz, 10, 10, 20, Colors.BLACK);}
    DrawFPS(GetScreenWidth() - 100, GetScreenHeight() - 50);
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
        debug debug_writeln("XNU/Darwin version detected");
    }
    debug_writeln("Engine version: ", ver);
    Vector3 targetPosition = { 10.0f, 0.0f, 20.0f };
    SetExitKey(0);
    float fadeAlpha = 2.0f;
    uint seed = cast(uint)Clock.currTime().toUnixTime();
    auto rnd = Random(seed);
    auto rnd_sec = Random(seed);
    
    encounterThreshold = uniform(900, 3000, rnd);
    randomNumber = uniform(1, 4, rnd_sec);
    
    // Window and Audio Initialization
    InitWindow(screenWidth, screenHeight, cast(char*)window_name);
    DisableCursor();
    ToggleFullscreen();
    Font navFont = LoadFont("res/font_16x16_en.png");
    SetTargetFPS(FPS);
    fontdialog = LoadFont("res/font_en.png");
    // Fade In and Out Effects
    InitAudioDevice();
    debug_writeln("Showing logo..");
    debug {
        if (play == false) { videoFinished = true; goto debug_lab; }
    }
    else {
        fadeEffect(0.0f, true, "powered by\n\nHeaven Engine");
        fadeEffect(fadeAlpha, false, "powered by\n\nHeaven Engine");
        //fadeEffectLogo(0.0f, true, "atlus_logo.png".toStringz, true);
        //fadeEffectLogo(fadeAlpha, false, "atlus_logo.png".toStringz, true);
        fadeEffect(0.0f, true, "under\n\nlevel\n\npresents");
        fadeEffect(fadeAlpha, false, "under\n\nlevel\n\npresents");
        // Play Opening Video
        BeginDrawing();
        version (Windows) {
            playVideo(cast(char*)("/"~getcwd()~"/res/videos/soul_OP.moflex.mp4"));
        }
        version (Posix) {
            playVideo(cast(char*)(getcwd()~"/res/videos/soul_OP.moflex.mp4"));
        }
    }
    debug_lab:
    //videoFinished = true;
    ClearBackground(Colors.BLACK);
    EndDrawing();
    // Load Control Configuration and Initialize Audio
    controlConfig = loadControlConfig();
    showMainMenu(currentGameState);
    // Lua Initialization
    debug { 
        debug_writeln("loading lua");
    }
    L = luaL_newstate();
    luaL_openlibs(L);
    luaL_registerAllLibraries(L);
    // Load Lua Script
    debug {
        debug_writeln("Executing next lua file: ", lua_exec);
        if (luaL_dofile(L, cast(char*)lua_exec) != LUA_OK) {
            debug_writeln("Lua error: ", to!string(lua_tostring(L, -1)));
            debug_writeln("Non-typical situation occured. Fix the script or contact developers.");
            return;
        }
    } else {
        if (luaL_dofile(L, "scripts/00_script.bin") != LUA_OK) {
            writeln("Lua error: ", to!string(lua_tostring(L, -1)));
            writeln("Non-typical situation occured. Contact developers.");
            return;
        }
    }
    initWindowAndCamera(camera);
    // Load Models
    float cameraSpeed = 5.0f;
    float radius = Vector3Distance(camera.position, camera.target);
    
    // Load gltf model animations
    int animsCount = 0;
    int animCurrentFrame = 0;
    ModelAnimation* modelAnimations = LoadModelAnimations("res/mc.glb", &animsCount);
    // Lighting Setup
    //modelCharacterSize = 5.0f;
    luaL_initDialogs(L);
    DisableCursor();
    // Gamepad Mappings
    SetGamepadMappings("030000005e040000ea020000050d0000,Xbox Controller,a:b0,b:b1,x:b2,y:b3,back:b6,guide:b8,start:b7,leftstick:b9,rightstick:b10,leftshoulder:b4,rightshoulder:b5,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,    dpright:h0.2;
        030000004c050000c405000011010000,PS4 Controller,a:b1,b:b2,x:b0,y:b3,back:b8,guide:b12,start:b9,leftstick:b10,rightstick:b11,leftshoulder:b4,rightshoulder:b5,dpup:b11,dpdown:b14,dpleft:b7,dpright:b15,leftx:a0,lefty:a1,rightx:a2,righty:a5,lefttrigger:a3,righttrigger:a4;");
    foreach (i, cubeModel; cubeModels) {
        cubes[i].rotation = 0.0f;
    }
    // Main Game Loop
    while (WindowShouldClose() == false) {
        SetExitKey(0);
        // Check if the window should close
        if (WindowShouldClose()) {
            debug_writeln("Window initialization error");
            return;
        }
        if (videoFinished) {
            switch (currentGameState) {
                case GameState.MainMenu:
                    showMainMenu(currentGameState);
                    break;
                case GameState.InGame:
                    if (shadersReload == 1) {
                        if (shaderEnabled == true) {
                            int fogDensityLoc = GetShaderLocation(shader, "fogDensity");
                            float fogDensity = 0.026f; // Initial fog density
                            SetShaderValue(shader, fogDensityLoc, &fogDensity, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
                            // Set Shader Locations
                            shader.locs[ShaderLocationIndex.SHADER_LOC_MATRIX_MODEL] = GetShaderLocation(shader, "matModel");
                            shader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW] = GetShaderLocation(shader, "viewPos");
                            int ambientLoc = GetShaderLocation(shader, "ambient");
                            float[4] values = [ 0.00005f, 0.00005f, 0.00005f, 1.0f ]; // Уменьшаем яркость окружающего света
                            SetShaderValue(shader, ambientLoc, &values[0], ShaderUniformDataType.SHADER_UNIFORM_VEC4);
                            assignShaderToModel(playerModel);
                            foreach (ref cubeModel; cubeModels) {
                                assignShaderToModel(cubeModel);
                            }
                            for (int z = 0; z < floorModel.length; z++) assignShaderToModel(floorModel[z]);
                            debug_writeln("Lights size before clean and after shader reloading:", lights);
                            for (int i = 0; i < light_pos.length; i++) {
                                lights[i] = CreateLight(LightType.LIGHT_POINT, light_pos[i], Vector3Zero(), Colors.WHITE, shader);
                            }
                            lights = null;
                            light_pos = null;
                            debug_writeln("Lights size after clean and after shader reloading:", lights);
                        }
                        shadersReload = 0;
                    }
                    deltaTime = GetFrameTime();
                    if (audioEnabled) {
                        UpdateMusicStream(music);
                    }
                    if (shaderEnabled) {
                        UpdateLightValues(shader, lights[0]);
                    }
                    luaL_updateDialog(L);
                    // Update camera and player positions
                    controlFunction(camera, cubePosition, controlConfig.forward_button, controlConfig.back_button, controlConfig.left_button, controlConfig.right_button, allowControl, deltaTime, cameraSpeed);
                    rotateCamera(camera, cubePosition, cameraAngle, rotationStep, radius);
                    BeginDrawing();
                    ClearBackground(Colors.BLACK);
                    if (isNewLocationNeeded == true) {
                        playerStepCounter = 0;
                        cubePosition = Vector3(0, 0, 0);
                        camera.position = Vector3(0, 5, 0.1);
                        camera.target = Vector3(0, 5, 0);
                        cameraAngle = 90.0f;
                        for (int i = 0; i < floorModel.length; i++) UnloadModel(floorModel[i]);
                        isNewLocationNeeded = false;
                        for (int i = 0; i < floorModel.length; i++) assignShaderToModel(floorModel[i]);
                    }
                    if (IsKeyDown(controlConfig.forward_button) || GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_Y) < -0.3 || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP) ||
                    IsKeyDown(controlConfig.back_button) || GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_Y) > 0.3 || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN) ||
                    IsKeyDown(controlConfig.left_button) || GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_X) < -0.3 || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT)|| 
                    IsKeyDown(controlConfig.right_button) || GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_X) > 0.3 || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT)) {
                        currentFrame = 0;
                        ModelAnimation anim;
                        if (IsKeyDown(KeyboardKey.KEY_LEFT_SHIFT) || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_LEFT)) {
                            anim = modelAnimations[modelAnimationRun];
                        } else {
                            anim = modelAnimations[modelAnimationWalk];
                        }
                        animCurrentFrame = (animCurrentFrame + 1)%anim.frameCount;
                        UpdateModelAnimation(playerModel, anim, animCurrentFrame);
                    } else {
                        currentFrame = 0;
                        ModelAnimation anim = modelAnimations[modelAnimationIdle];
                        animCurrentFrame = (animCurrentFrame + 1)%anim.frameCount;
                        UpdateModelAnimation(playerModel, anim, animCurrentFrame);
                        if (stamina < 25.0f) {
                            stamina += 0.2f;
                        } else if (stamina > 25.0f && stamina < 29.0f) {
                            stamina = 25.0f;
                        }
                    }
                    if (!showCharacterNameInputMenu && !neededDraw2D && !inBattle) {
                        DrawTexturePro(texture_skybox, Rectangle(0, 0, cast(float)texture_skybox.width, cast(float)texture_skybox.height), Rectangle(0, 0, cast(float)GetScreenWidth(), cast(float)GetScreenHeight()), Vector2(0, 0), 0.0, Colors.WHITE);
                        drawScene(floorModel, camera, cubePosition, cameraAngle, cubeModels, playerModel);
                    }
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
                    if (!isNaN(iShowSpeed) && !isNaN(neededDegree) && !isNewLocationNeeded) {
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
                    if (!friendlyZone && playerStepCounter >= encounterThreshold && !inBattle) {
                        enemies = new Enemy[randomNumber];
                        originalCubePosition = cubePosition;
                        originalCameraPosition = camera.position;
                        originalCameraTarget = camera.target;
                        if (audioEnabled) {
                            if (!isBossfight) {
                                uint audio_size;
                                char *audio_data = get_file_data_from_archive("res/data.bin", "battle.mp3", &audio_size);
                                StopMusicStream(music);
                                music = LoadMusicStreamFromMemory(".mp3", cast(const(ubyte)*)audio_data, audio_size);
                                PlayMusicStream(music);
                                UpdateMusicStream(music);
                            } else {
                                uint audio_size;
                                char *audio_data = get_file_data_from_archive("res/data.bin", "boss_battle.mp3", &audio_size);
                                StopMusicStream(music);
                                music = LoadMusicStreamFromMemory(".mp3", cast(const(ubyte)*)audio_data, audio_size);
                                PlayMusicStream(music);
                                UpdateMusicStream(music);
                            }
                        } else {
                            StopMusicStream(music);
                        }
                        allowControl = false;
                        playerStepCounter = 0;
                        encounterThreshold = uniform(900, 3000, rnd);
                        inBattle = true;
                        isBossfight = false;
                        initBattle(demonsAllowed);
                    }
                    if (inBattle) {
                        drawBattleMenu();
                    }
                    // Show Map Prompt
                    showMapPrompt = Vector3Distance(cubePosition, targetPosition) < 4.0f;
                    if (hintNeeded && !showInventory && !inBattle) {
                        if (!showDialog) {
                            Color semiTransparentBlack = Color(0, 0, 0, 200);
                            
                            // Measure the text size
                            Vector2 textSize = MeasureTextEx(fontdialog, toStringz(hint), 30, 1.0f);
                            
                            // Define padding around the text
                            int padding = 20; // You can adjust this value as needed
                            
                            // Calculate the rectangle dimensions based on the text size and padding
                            int rectWidth = to!int(textSize.x + 2 * padding);
                            int rectHeight = to!int(textSize.y + 2 * padding);
                            
                            // Center the rectangle on the screen
                            int rectX = (GetScreenWidth() - rectWidth) / 2;
                            int rectY = (GetScreenHeight() - rectHeight) - rectHeight + (rectHeight / 2);
                            
                            // Calculate the text position within the rectangle
                            float textX = rectX + padding;
                            float textY = rectY + padding;
                            
                            // Draw the rectangle and text
                            DrawRectangleRounded(Rectangle(rectX, rectY, rectWidth, rectHeight), 0.03f, 16, semiTransparentBlack);
                            DrawRectangleRoundedLinesEx(Rectangle(rectX, rectY, rectWidth, rectHeight), 0.03f, 16, 5.0f, Color(100, 54, 65, 255));
                            DrawTextEx(fontdialog, toStringz(hint), Vector2(textX, textY), 30, 1.0f, Colors.WHITE);
                        }
                    }
                    if (showMapPrompt) {
                        const int posY = GetScreenHeight() - FontSize - 40;
                        if (IsGamepadAvailable(gamepadInt)) {
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

                        if (IsKeyPressed(controlConfig.dialog_button) || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) {
                            StopMusicStream(music);
                            openMap(location_name, false);
                        }
                    }
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
                    // Check Dialog Status
                    lua_getglobal(L, "_3dEventLoop");
                    if (lua_pcall(L, 0, 2, 0) == LUA_OK) {
                        lua_pop(L, 2);
                    } else {
                        debug_writeln("Error in _3dEventLoop: ", to!string(lua_tostring(L, -1)));
                    }

                    // Draw Debug Information
                    if (showDebug) {
                        drawDebugInfo(cubePosition, currentGameState, partyMembers[0].currentHealth, cameraAngle, playerStepCounter, 
                        encounterThreshold, inBattle);
                    }

                    // Inventory Handling
                    if (IsKeyPressed(controlConfig.opmenu_button) && !showDialog || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_UP) && !showDialog) {
                        showInventory = true;
                    }
                    if (showInventory) {
                        drawInventory();
                    }
                    EndDrawing();
                    break;
                case GameState.Exit:
                    StopMusicStream(music);
                    EndDrawing();
                    CloseWindow();
                    UnloadFont(fontdialog);
                    for (int i = tex2d.length; i < tex2d.length; i++) {
                        UnloadTexture(tex2d[i].texture);
                    }
                    for (int i = backgrounds.length; i < backgrounds.length; i++) {
                        UnloadTexture(backgrounds[i]);
                    }
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