module graphics.gamelogic;

import raylib;
import bindbc.lua;
import variables;
import scripts.config;
import core.stdc.stdlib;
import core.stdc.time;
import graphics.engine;
import scripts.lua;
import std.stdio;
import std.conv;
import graphics.effects;
import raylib_lights;
import std.string;
import graphics.battle;
import graphics.cubes;
import std.math;
import graphics.scene;
import ui.flicker;
import ui.navigator;
import dialogs.dialog_system;
import ui.inventory;

/** 
 * this module contains game logic, which was removed from engine.d for better readability.
 */

enum
{
    MIN_ENCOUNTER_THRESHOLD = 900,
    MAX_ENCOUNTER_THRESHOLD = 3000,
    STAMINA_RECOVERY_RATE = 0.2f,
    MAX_STAMINA = 25.0f,
    STAMINA_THRESHOLD = 29.0f,
    HINT_PADDING = 20,
    HINT_ROUNDNESS = 0.03f,
    HINT_LINE_THICKNESS = 5.0f
}

immutable float FOG_DENSITY = 0.026f;

void gameInit()
{
    if (WindowShouldClose()) {
        currentGameState = GameState.Exit;
    } else {
        debug_writeln("Game initializing.");
        encounterThreshold = uniform(MIN_ENCOUNTER_THRESHOLD, MAX_ENCOUNTER_THRESHOLD);
        randomNumber = rand() % 4;
        controlConfig = loadControlConfig();
        if (sfxEnabled == false) {
            UnloadSound(audio.menuMoveSound);
            UnloadSound(audio.acceptSound);
            UnloadSound(audio.menuChangeSound);
            UnloadSound(audio.declineSound);
            UnloadSound(audio.nonSound);
        }
    }
}

void luaInit(string lua_exec)
{
    debug_writeln("loading Lua");
    L = luaL_newstate();
    luaL_openlibs(L);
    luaL_registerAllLibraries(L);

    debug
    {
        debug_writeln("Executing next lua file: ", lua_exec);
        if (luaL_dofile(L, toStringz(lua_exec)) != LUA_OK)
        {
            debug_writeln("Lua error: ", to!string(lua_tostring(L, -1)));
            debug_writeln("Non-typical situation occured. Fix the script or contact developers.");
            return;
        }
    }
    else
    {
        if (luaL_dofile(L, "scripts/00_script.bin") != LUA_OK)
        {
            writeln("Script execution error: ", to!string(lua_tostring(L, -1)));
            writeln("Non-typical situation occured. Tell developers about it!");
            return;
        }
    }
}

void navigationDrawLogic(Font navFont)
{
    float colorIntensity = !friendlyZone && playerStepCounter < encounterThreshold ?
        1.0f - (cast(float)(encounterThreshold - playerStepCounter) / encounterThreshold) : 0.0f;
    if (show_sec_dialog && showDialog)
    {
        allow_exit_dialog = allowControl = false;
        displayDialog(name_global, emotion_global, message_global, pageChoice_glob);
    }

    if (!showDialog)
    {
        int colorChoice;
        if (colorIntensity > 0.75)
            colorChoice = 3;
        else if (colorIntensity > 0.5)
            colorChoice = 2;
        else if (colorIntensity > 0.25)
            colorChoice = 1;
        else
            colorChoice = 0;

        if (!inBattle && !friendlyZone && !hideNavigation)
        {
            drawFlickeringRhombus(colorChoice);
        }
    }

    if (!inBattle && !showInventory && !showDialog && !hideNavigation)
    {
        drawNavigation(cameraAngle, navFont, fontdialog);
    }
}

void playerLogic(float cameraSpeed)
{
    updatePlayerOBB(playerOBB, cubePosition, modelCharacterSize, playerModelRotation);
    controlFunction(camera, cubePosition,
        controlConfig.forward_button,
        controlConfig.back_button,
        controlConfig.left_button,
        controlConfig.right_button,
        allowControl, deltaTime, cameraSpeed);
}

void shadersLogic()
{
    if (shadersReload != 1)
        return;

    if (shaderEnabled)
    {
        int fogDensityLoc = GetShaderLocation(shader, "fogDensity");
        SetShaderValue(shader, fogDensityLoc, &FOG_DENSITY, ShaderUniformDataType
                .SHADER_UNIFORM_FLOAT);

        shader.locs[ShaderLocationIndex.SHADER_LOC_MATRIX_MODEL] = GetShaderLocation(shader, "matModel");
        shader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW] = GetShaderLocation(shader, "viewPos");

        int ambientLoc = GetShaderLocation(shader, "ambient");
        float[4] values = [0.05f, 0.05f, 0.05f, 1.0f];
        SetShaderValue(shader, ambientLoc, &values[0], ShaderUniformDataType.SHADER_UNIFORM_VEC4);

        assignShaderToModel(playerModel);
        foreach (ref cubeModel; cubeModels)
        {
            assignShaderToModel(cubeModel);
        }

        foreach (ref model; floorModel)
        {
            assignShaderToModel(model);
        }

        debug debug_writeln("Lights size before clean and after shader reloading:", lights);

        lights.length = 0; // Очищаем массив lights
        foreach (ref pos; light_pos)
        {
            lights ~= CreateLight(LightType.LIGHT_POINT, pos.lights, Vector3Zero(), pos.color, shader);
        }

        debug debug_writeln("Lights size after clean and after shader reloading:", lights);

        foreach (ref light; lights)
        {
            UpdateLightValues(shader, light);
        }
    }

    shadersReload = 0;
}

void cameraLogic(ref Camera3D camera, float fov)
{
    if (updateCamera)
    {
        camera = Camera3D(positionCam, targetCam, upCam, fov, CameraProjection.CAMERA_PERSPECTIVE);
        radius = Vector3Distance(camera.position, camera.target);
        updateCamera = false;
    }

    if (!isNaN(iShowSpeed) && !isNaN(neededDegree))
    {
        rotateScriptCamera(camera, cubePosition, cameraAngle, neededDegree, iShowSpeed, radius, deltaTime);
    }
    rotateCamera(camera, cubePosition, cameraAngle, rotationStep, radius);
}

void luaEventLoop()
{
    lua_getglobal(L, "EventLoop");
    if (lua_pcall(L, 0, 0, 0) != LUA_OK)
    {
        debug debug_writeln("Error in EventLoop: ", to!string(lua_tostring(L, -1)));
    }
    lua_pop(L, 0);
}

void vnLogic()
{
    if (neededDraw2D)
    {
        allowControl = false;
        DrawTexturePro(texture_background, Rectangle(0, 0, cast(float) texture_background.width, cast(
                float) texture_background.height), Rectangle(0, 0, cast(float) GetScreenWidth(), cast(
                float) GetScreenHeight()), Vector2(0, 0), 0.0, Colors.WHITE);
    }
    if (neededCharacterDrawing)
    {
        allowControl = false;
        for (int i = 0; i < tex2d.length; i++)
        {
            float centeredX = tex2d[i].x - (tex2d[i].width * tex2d[i].scale / 2);
            float centeredY = tex2d[i].y - (tex2d[i].height * tex2d[i].scale / 2);
            
            DrawTextureEx(tex2d[i].texture, 
                        Vector2(centeredX, centeredY), 
                        0.0, 
                        tex2d[i].scale, 
                        Colors.WHITE);
        }
    }
    if (!neededDraw2D && !inBattle) {
        DrawTexturePro(texture_skybox, Rectangle(0, 0, cast(float) texture_skybox.width, cast(float) texture_skybox
                .height), Rectangle(0, 0, cast(float) GetScreenWidth(), cast(float) GetScreenHeight()), Vector2(0, 0), 0.0, Colors
                .WHITE);
        drawScene(camera, cubePosition, cameraAngle, cubeModels, playerModel);
    }
    playUIAnimation(framesUI);
}

void animationsLogic(ref int animCurrentFrame, ModelAnimation* modelAnimations, bool collisionDetected)
{
    if (animations != 1 || modelAnimations is null)
        return;
    ModelAnimation anim;

    bool isMoving = collisionDetected == false && allowControl == true && (
        IsKeyDown(controlConfig.forward_button) ||
            GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_Y) < -0.3 ||
            IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP) ||
            IsKeyDown(controlConfig.back_button) ||
            GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_Y) > 0.3 ||
            IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN) ||
            IsKeyDown(controlConfig.left_button) ||
            GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_X) < -0.3 ||
            IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT) ||
            IsKeyDown(controlConfig.right_button) ||
            GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_X) > 0.3 ||
            IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT)
    );

    if (isMoving)
    {
        bool isRunning = IsKeyDown(KeyboardKey.KEY_LEFT_SHIFT) ||
            IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_LEFT);

        anim = modelAnimations[isRunning ? modelAnimationRun: modelAnimationWalk];
    }
    else
    {
        anim = modelAnimations[modelAnimationIdle];

        if (stamina < MAX_STAMINA)
        {
            stamina += STAMINA_RECOVERY_RATE;
        }
        else if (stamina > MAX_STAMINA && stamina < STAMINA_THRESHOLD)
        {
            stamina = MAX_STAMINA;
        }
    }

    animCurrentFrame = (animCurrentFrame + 1) % anim.frameCount;
    UpdateModelAnimation(playerModel, anim, animCurrentFrame);
}

void showHintLogic()
{
    if (!hintNeeded || showInventory || inBattle)
        return;

    Color semiTransparentBlack = Color(0, 0, 0, 200);
    Vector2 textSize = MeasureTextEx(fontdialog, toStringz(hint), 30, 1.0f);

    int rectWidth = to!int(textSize.x + 2 * HINT_PADDING);
    int rectHeight = to!int(textSize.y + 2 * HINT_PADDING);
    int rectX = (GetScreenWidth() - rectWidth) / 2;
    int rectY = (GetScreenHeight() - rectHeight) - rectHeight + (rectHeight / 2);

    float textX = rectX + HINT_PADDING;
    float textY = rectY + HINT_PADDING;

    DrawRectangleRounded(Rectangle(rectX, rectY, rectWidth, rectHeight),
        HINT_ROUNDNESS, 16, semiTransparentBlack);
    DrawRectangleRoundedLinesEx(Rectangle(rectX, rectY, rectWidth, rectHeight),
        HINT_ROUNDNESS, 16, HINT_LINE_THICKNESS, Color(100, 54, 65, 255));
    DrawTextEx(fontdialog, toStringz(hint), Vector2(textX, textY), 30, 1.0f, Colors.WHITE);
}

void inventoryLogic()
{
    if ((IsKeyPressed(controlConfig.opmenu_button) || IsGamepadButtonPressed(gamepadInt, GamepadButton
            .GAMEPAD_BUTTON_RIGHT_FACE_UP)) && !showDialog && !isCameraRotating)
    {
        debug debug_writeln("opening inventory...");
        if (sfxEnabled) PlaySound(audio.acceptSound);
        showInventory = true;
    }
    if (showInventory)
    {
        drawInventory();
    }
}

void debugLogic()
{
    debug
    {
        if (IsKeyPressed(KeyboardKey.KEY_F4))
        {
            playerStepCounter = encounterThreshold + 1;
        }
        if (IsKeyPressed(KeyboardKey.KEY_F3) && currentGameState == GameState.InGame)
        {
            showDebug = !showDebug;
        }
        // Draw Debug Information
        if (showDebug)
        {
            drawDebugInfo(cubePosition, currentGameState, partyMembers[0].currentHealth, cameraAngle, playerStepCounter,
                encounterThreshold, inBattle);
        }
    }
}

void battleInitLogic()
{
    if (friendlyZone || playerStepCounter < encounterThreshold || inBattle)
        return;

    if (audioEnabled)
    {
        string musicFile = isBossfight ? "boss_battle.mp3" : "battle.mp3";
        uint audio_size;
        char* audio_data = get_file_data_from_archive("res/data.bin", toStringz(musicFile), &audio_size);

        StopMusicStream(music);
        music = LoadMusicStreamFromMemory(".mp3", cast(const(ubyte)*) audio_data, audio_size);
        PlayMusicStream(music);
        UpdateMusicStream(music);
    }
    else
    {
        StopMusicStream(music);
    }

    allowControl = false;
    playerStepCounter = 0;
    encounterThreshold = uniform(MIN_ENCOUNTER_THRESHOLD, MAX_ENCOUNTER_THRESHOLD);
    inBattle = true;
    isBossfight = false;
    initBattle(demonsAllowed);
}

void battleLogic()
{
    if (inBattle)
    {
        drawBattleMenu();
    }
}

void moveCubes()
{
    foreach (ref cube; cubes)
    {
        if (!cube.isMoving)
            continue;

        float elapsedTime = GetTime() - cube.moveStartTime;
        if (elapsedTime >= cube.moveDuration)
        {
            cube.boundingBox.min = cube.endPosition;
            cube.isMoving = false;
            beginNextMove(cube);
        }
        else
        {
            float t = elapsedTime / cube.moveDuration;
            cube.boundingBox.min = Vector3Lerp(cube.startPosition, cube.endPosition, t);
            cube.boundingBox.max = Vector3Add(cube.boundingBox.min, Vector3(2.0f, 2.0f, 2.0f));
        }
    }
}

int uniform(int a, int b)
{
    return a + rand() % (b - a + 1);
}