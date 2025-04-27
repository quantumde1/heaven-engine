module graphics.gamelogic;

import raylib;
import bindbc.lua;
import variables;
import scripts.config;
import core.stdc.stdlib;
import core.stdc.time;
import graphics.engine;
import scripts.lua;
import std.conv;
import raylib_lights;
import std.string;
import graphics.battle;

void gameInit() {
    debug_writeln("Game initializing.");
    encounterThreshold = rand() % (3000 - 900 + 1) + 900;
    randomNumber = rand % 4;
    controlConfig = loadControlConfig();
}

void luaInit(string lua_exec) {
    debug_writeln("loading Lua");
    L = luaL_newstate();
    luaL_openlibs(L);
    luaL_registerAllLibraries(L);
    // Load Lua Script
    debug {
        debug debug_writeln("Executing next lua file: ", lua_exec);
        if (luaL_dofile(L, cast(char*)lua_exec) != LUA_OK) {
            debug debug_writeln("Lua error: ", to!string(lua_tostring(L, -1)));
            debug debug_writeln("Non-typical situation occured. Fix the script or contact developers.");
            return;
        }
    } else {
        if (luaL_dofile(L, "scripts/00_script.bin") != LUA_OK) {
            writeln("Script execution error: ", to!string(lua_tostring(L, -1)));
            writeln("Non-typical situation occured. Contact developers.");
            return;
        }
    }
}

void shadersLogic() {
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
            debug debug_writeln("Lights size before clean and after shader reloading:", lights);
            for (int i = 0; i < light_pos.length; i++) {
                lights ~= CreateLight(LightType.LIGHT_POINT, light_pos[i].lights, Vector3Zero(), 
                light_pos[i].color, shader);
            }
            debug debug_writeln("Lights size after clean and after shader reloading:", lights);
            for (int i = 0; i < lights.length; i++) {
                UpdateLightValues(shader, lights[i]);
            }
        }
        shadersReload = 0;
    }
}

void cameraLogic(ref Camera3D camera, float fov) {
    if (updateCamera == true) {
        CameraProjection projection = CameraProjection.CAMERA_PERSPECTIVE;
        camera = Camera3D(positionCam, targetCam, upCam, fov, projection);
        radius = Vector3Distance(camera.position, camera.target);
        updateCamera = false;
    }
}

void luaEventLoop() {
    //2d loop worker
    lua_getglobal(L, "EventLoop");
    if (lua_pcall(L, 0, 0, 0) == LUA_OK) {
        lua_pop(L, 0);
    } else {
        debug {
            debug debug_writeln("Error in _2dEventLoop: ", to!string(lua_tostring(L, -1)));
        }
    }
}

void animationsLogic(ref int currentFrame, ref int animCurrentFrame, ModelAnimation* modelAnimations, bool collisionDetected) {
    if (collisionDetected == false && allowControl == true && (IsKeyDown(controlConfig.forward_button) || GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_Y) < -0.3 || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP) ||
        IsKeyDown(controlConfig.back_button) || GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_Y) > 0.3 || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN) ||
        IsKeyDown(controlConfig.left_button) || GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_X) < -0.3 || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT)|| 
        IsKeyDown(controlConfig.right_button) || GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_X) > 0.3 || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT))) {
        
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
}

void showHintLogic() {
    if (hintNeeded && !showInventory && !inBattle) {
        if (!showDialog) {
            Color semiTransparentBlack = Color(0, 0, 0, 200);
            
            // Measure the text size
            Vector2 textSize = MeasureTextEx(fontdialog, toStringz(hint), 30, 1.0f);
            
            // Define padding around the text
            int padding = 20;
            
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
}

void battleLogic() {
    if (!friendlyZone && playerStepCounter >= encounterThreshold && !inBattle) {
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
        encounterThreshold = rand() % (3000 - 900 + 1) + 900;
        inBattle = true;
        isBossfight = false;
        initBattle(demonsAllowed);
    }
    if (inBattle) {
        drawBattleMenu();
    }
}