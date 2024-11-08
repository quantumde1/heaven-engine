// quantumde1 developed software, licensed under BSD-0-Clause license.
module scripts.lua_engine;

import bindbc.lua;
import raylib;
import variables;
import std.stdio;
import std.conv;
import script;
import graphics.cubes;
import std.string;
import graphics.main_loop;
import graphics.scene;
import ui.battle_ui;
import graphics.video_playback;
import std.file;

/* 
 * This module provides Lua bindings for various engine functionalities.
 * Functions are built on top of engine built-in functions for execution from scripts.
 * Not all engine functions usable for scripting are yet implemented.
*/

extern (C) nothrow int lua_initBattle(lua_State *L) {
    originalCubePosition = cubePosition;
    originalCameraPosition = camera.position;
    originalCameraTarget = camera.target;
    StopMusicStream(music);
    allowControl = false;
    bool isBoss;
    if (luaL_checkinteger(L, 2) == 1) {
        isBoss = true;
    } else {
        isBoss = false;
    }
    playerStepCounter = 0;
    inBattle = true;
    try {
        initBattle(camera, cubePosition, cameraAngle, to!int(luaL_checkinteger(L, 1))-1,isBoss);
    } catch (Exception e) {

    }
    return 0;
}

extern (C) nothrow lua_getBattleStatus(lua_State *L) {
    //status mean ended or not
    lua_pushboolean(L, inBattle);
    return 1;
}

extern (C) nothrow int lua_getAnswerValue(lua_State *L) {
    lua_pushinteger(L, answer_num);
    return 1;
}

// Lua State Functions
extern (C) nothrow int lua_isDialogExecuted(lua_State *L) {
    lua_pushboolean(L, event_initialized);
    return 1; // Number of return values
}

extern (C) nothrow int lua_removeCube(lua_State *L) {
    try { if (!rel) {
    writeln("Removing: ", to!string(luaL_checkstring(L, 1))); }
    removeCube(to!string(luaL_checkstring(L, 1)));
    } catch (Exception e) {}
    return 0;
}

extern (C) nothrow int lua_changeCameraPosition(lua_State *L) {
    positionCam = Vector3(
        luaL_checknumber(L, 1),
        luaL_checknumber(L, 2),
        luaL_checknumber(L, 3)
    );
    return 0;
}

extern (C) nothrow int lua_changeCameraUp(lua_State *L) {
    upCam = Vector3(
        luaL_checknumber(L, 1),
        luaL_checknumber(L, 2),
        luaL_checknumber(L, 3)
    );
    return 0;
}

extern (C) nothrow int lua_changeCameraTarget(lua_State *L) {
    targetCam = Vector3(
        luaL_checknumber(L, 1),
        luaL_checknumber(L, 2),
        luaL_checknumber(L, 3)
    );
    return 0;
}

extern (C) nothrow int lua_getDialogName(lua_State *L) {
    lua_pushstring(L, name_global.toStringz());
    return 1; // Number of return values
}

extern (C) nothrow int luaL_loadlocation(lua_State* L) {
    loadLocation(cast(char*)luaL_checkstring(L, 1));
    return 0;
}

extern (C) nothrow int luaL_dialogAnswerValue(lua_State* L) {
    lua_pushinteger(L, answer_num); // Push the integer value onto the Lua stack
    return 1;
}

extern (C) nothrow int luaL_rotateCam(lua_State* L) {
    isCameraRotating = true;
    iShowSpeed = luaL_checknumber(L, 2);
    neededDegree = luaL_checknumber(L, 1);
    return 0;
}

extern (C) void luaL_initDialogs(lua_State* L) {
    lua_getglobal(L, "initDialogs");
    lua_pcall(L, 0, 0, 0); // Call the initDialogs function in Lua
}

extern (C) void luaL_updateDialog(lua_State* L) {
    lua_getglobal(L, "updateDialog");
    lua_pcall(L, 0, 0, 0); // Call the updateDialog function in Lua
}

extern (C) nothrow int luaL_dialogClearChoice(lua_State *L) {
    for (int i = 0; i <= choices.length; i++) {
        choices[i] = "";
    }
    return 0;
}

extern (C) nothrow int luaL_dialogBox(lua_State *L) {
    name_global = luaL_checkstring(L, 1).to!string;  // Update dialog name
    event_initialized = true;
    luaL_checktype(L, 2, LUA_TTABLE);
    
    int textTableLength = cast(int)lua_objlen(L, 2);
    message_global = new string[](textTableLength); // Allocate exact size needed
    
    for (int i = 0; i < textTableLength; i++) { // Start index from 0
        lua_rawgeti(L, 2, i + 1); // Lua indices start from 1
        message_global[i] = luaL_checkstring(L, -1).to!string;
        lua_pop(L, 1);
    }
    
    pageChoice_glob = cast(int)luaL_checkinteger(L, 4);
    emotion_global = cast(int)luaL_checkinteger(L, 3);
    
    // Get the choices array from the Lua stack
    luaL_checktype(L, 5, LUA_TTABLE);
    int choicesLength = cast(int)lua_objlen(L, 5);
    choices = new string[choicesLength];
    for (int i = 0; i < choicesLength; i++) {
        lua_rawgeti(L, 5, i + 1); // Lua indices start from 1
        choices[i] = luaL_checkstring(L, -1).to!string;
        lua_pop(L, 1);
    }
    if (lua_gettop(L) == 6) {
        typingSpeed = cast(float)luaL_checknumber(L, 6);
    } else {
        typingSpeed = 0.03f;
    }
    showDialog = true;
    allowControl = false;
    show_sec_dialog = true;
    
    return 0;
}

extern (C) nothrow int lua_updateCubeDialog(lua_State *L) {
    auto name = luaL_checkstring(L, 1).to!string;
    luaL_checktype(L, 2, LUA_TTABLE);
    
    bool cubeFound = false;
    
    // Update the cube dialog text
    foreach (ref cube; cubes) {
        if (cube.name == name) {
            int textTableLength = cast(int)lua_objlen(L, 2);
            cube.text = new string[](textTableLength);
            for (int i = 1; i <= textTableLength; i++) {
                lua_rawgeti(L, 2, i);
                cube.text[i - 1] = luaL_checkstring(L, -1).to!string;
                lua_pop(L, 1);
            }
            cubeFound = true;
            break;
        }
    }

    // If cube with the given name is not found, raise an error
    try {
    if (!cubeFound) {
        writeln("Error: Cube not found: ", name);
    }
    } catch (Exception e) {

    }
    return 0;
}

// Register the dialog functions
extern (C) nothrow void luaL_opendialoglib(lua_State* L) {
    lua_register(L, "dialogBox", &luaL_dialogBox);
    lua_register(L, "dialogAnswerValue", &luaL_dialogAnswerValue);
    lua_register(L, "loadLocation", &luaL_loadlocation);
    lua_register(L, "initBattle", &lua_initBattle);
    lua_register(L, "isDialogExecuted", &lua_isDialogExecuted);
    lua_register(L, "getBattleStatus", &lua_getBattleStatus);
    lua_register(L, "getDialogName", &lua_getDialogName);
    lua_register(L, "updateCubeDialog", &lua_updateCubeDialog);
    lua_register(L, "getAnswerValue", &lua_getAnswerValue);
    lua_register(L, "clearChoice", &luaL_dialogClearChoice);
}

// Music functions
extern (C) nothrow int lua_LoadMusic(lua_State *L) {
    try {
        musicpath = cast(char*)luaL_checkstring(L, 1);
        uint audio_size;
        char *audio_data = get_file_data_from_archive("res/data.bin", musicpath, &audio_size);
        
        if (isAudioEnabled()) {
            UnloadMusicStream(music);
            music = LoadMusicStreamFromMemory(".mp3", cast(const(ubyte)*)audio_data, audio_size);
        }
    } catch (Exception e) {
    }
    return 0;
}

extern (C) nothrow int lua_startCubeRotation(lua_State *L) {
    try {
        cubeIndex = cast(int)luaL_checkinteger(L, 1) - 1;
        targetAngle = cast(float) luaL_checknumber(L, 2);
        targetSpeed = cast(float) luaL_checknumber(L, 3);
        duration = cast(float) luaL_checknumber(L, 4);
        if (cubeIndex >= 0 && cubeIndex < cubes.length) {
            rotateCube(cubes[cubeIndex], targetAngle, targetSpeed, duration);
        } else {
            luaL_error(L, "Invalid cube index");
        }
    } catch (Exception e) {

    }
    return 0;
}

extern (C) nothrow int lua_startCubeMove(lua_State *L) {
    int cubeIndex = cast(int)luaL_checkinteger(L, 1) - 1;
    Vector3 endPosition = {
        cast(float) luaL_checknumber(L, 2),
        cast(float) luaL_checknumber(L, 3),
        cast(float) luaL_checknumber(L, 4)
    };
    float duration = cast(float) luaL_checknumber(L, 5);
    if (cubeIndex >= 0 && cubeIndex < cubes.length) {
        startCubeMove(cubes[cubeIndex], endPosition, duration);
    } else {
        luaL_error(L, "Invalid cube index");
    }
    return 0;
}

// Register the movement functions
extern (C) nothrow void luaL_openmovelib(lua_State* L) {
    lua_register(L, "startCubeMove", &lua_startCubeMove);
    lua_register(L, "startCubeRotation", &lua_startCubeRotation);
    lua_register(L, "changeCameraUp", &lua_changeCameraUp);
    lua_register(L, "changeCameraTarget", &lua_changeCameraTarget);
    lua_register(L, "changeCameraPosition", &lua_changeCameraPosition);
}

// Music control functions
extern (C) nothrow int lua_PlayMusic(lua_State *L) {
    PlayMusicStream(music);
    return 0;
}

extern (C) nothrow int lua_StopMusic(lua_State *L) {
    StopMusicStream(music);
    return 0;
}

extern (C) nothrow int lua_getCubeXPos(lua_State *L) {
    lua_pushnumber(L, cast(int)cubePosition.x);
    return 1;
}

extern (C) nothrow int lua_getCubeYPos(lua_State *L) {
    lua_pushnumber(L, cast(int)cubePosition.y);
    return 1;
}

extern (C) nothrow int lua_getCubeZPos(lua_State *L) {
    lua_pushnumber(L, cast(int)cubePosition.z);
    return 1;
}

// Cube management functions
extern (C) nothrow int lua_addCube(lua_State *L) {
    auto name = luaL_checkstring(L, 4);
    int emotion = cast(int) luaL_checkinteger(L, 6);
    Vector3 position = {
        cast(float) luaL_checknumber(L, 1),
        cast(float) luaL_checknumber(L, 2),
        cast(float) luaL_checknumber(L, 3)
    };
    
    luaL_checktype(L, 5, LUA_TTABLE);
    int textTableLength = cast(int)lua_objlen(L, 5);
    string[] textPages = new string[](textTableLength); 
    
    for (int i = 1; i <= textTableLength; i++) {
        lua_rawgeti(L, 5, i);
        textPages[i - 1] = luaL_checkstring(L, -1).to!string;
        lua_pop(L, 1);
    }
    int choicePage = cast(int)luaL_checkinteger(L, 7);
    addCube(position, name.to!string, textPages, emotion, choicePage);
    return 0;
}

extern (C) nothrow int lua_setMcModel(lua_State *L) {
    playerModel = LoadModel(luaL_checkstring(L, 1));
    return 0;
}

extern (C) nothrow int lua_setCubeModel(lua_State *L) {
    int index = cast(int)luaL_checkinteger(L, 1) - 1;
    const char* modelPath = luaL_checkstring(L, 2);
    cubeModels[index] = LoadModel(modelPath);
    return 0;
}

extern (C) nothrow int lua_removeCubeModel(lua_State *L) {
    int index = cast(int)luaL_checkinteger(L, 1) - 1;
    cubeModels = cubeModels[0 .. index] ~ cubeModels[index + 1 .. cubeModels.length];
    return 0;
}

extern (C) nothrow int lua_howMuchModels(lua_State *L) {
    int index = cast(int)luaL_checkinteger(L, 1);
    cubeModels = new Model[index];
    return 0;
}

extern (C) nothrow int lua_cubeMoveStatus(lua_State *L) {
    try {
    lua_pushboolean(L, isAnyCubeMoving());
    } catch (Exception e) {}
    return 1;
}

// Register drawing functions
extern (C) nothrow void luaL_opendrawinglib(lua_State* L) {
    lua_register(L, "addCube", &lua_addCube);
    lua_register(L, "isCubeMoving", &lua_cubeMoveStatus);
    lua_register(L, "setCubeModel", &lua_setCubeModel);
    lua_register(L, "removeCubeModel", &lua_removeCubeModel);
    lua_register(L, "getCubeX", &lua_getCubeXPos);
    lua_register(L, "getCubeY", &lua_getCubeYPos);
    lua_register(L, "getCubeZ", &lua_getCubeZPos);
    lua_register(L, "howMuchModels", &lua_howMuchModels);
    lua_register(L, "rotateCamera", &luaL_rotateCam);
    lua_register(L, "loadScript", &luaL_loadScript);
    lua_register(L, "setPlayerModel", &lua_setMcModel);
    lua_register(L, "removeCube", &lua_removeCube);
}

// Load and execute a Lua script
extern (C) nothrow int luaL_loadScript(lua_State *L) {
    if (luaL_dofile(L, luaL_checkstring(L, 1)) != 0) {
        lua_pop(L, 1); // Remove error message from stack
    }
    return 0;
}

// Register functions in Lua
extern (C) nothrow void luaL_openaudiolib(lua_State* L) {
    lua_register(L, "loadMusic", &lua_LoadMusic);
    lua_register(L, "playMusic", &lua_PlayMusic);
    lua_register(L, "stopMusic", &lua_StopMusic);
}

// Initialization function to register all libraries
extern (C) nothrow void luaL_registerAllLibraries(lua_State* L) {
    luaL_opendialoglib(L);
    luaL_openaudiolib(L);
    luaL_opendrawinglib(L);
    luaL_openmovelib(L);
}