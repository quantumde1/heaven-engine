//quantumde1 developed software, licensed under BSD-0-Clause license.
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

/* All functions here are built on top of engine built-in functions, for their execution from script.
Not all engine usable for scripting functions are yet implemented.*/

extern (C) nothrow int lua_isDialogExecuted(lua_State *L) {
    lua_pushboolean(L, event_initialized);
    return 1; // Number of return values
}

extern (C) nothrow int lua_getDialogName(lua_State *L) {
    lua_pushstring(L, name_global.toStringz());
    return 1; // Number of return values
}

extern (C) nothrow int luaL_loadlocation(lua_State* L) {
    loadLocation(cast(char*)luaL_checkstring(L, 1), luaL_checkstring(L, 2));
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
    try {
        if (!rel) {
            writeln("iShowSpeed: ", iShowSpeed, " neededDegree: ", neededDegree);
        }
    } catch (Exception e) {

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
    pageChoice_glob = cast(int)luaL_checkinteger(L,4);
    emotion_global = cast(int) luaL_checkinteger(L, 3);
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
    if (!cubeFound) {
        try {
            writeln("error not found:", name);
        } catch (Exception e) {

        }
    }
    
    return 0;
}

// Register the function
extern (C) nothrow void luaL_opendialoglib(lua_State* L) {
    lua_register(L, "dialogBox", &luaL_dialogBox);
    lua_register(L, "dialogAnswerValue", &luaL_dialogAnswerValue);
    lua_register(L, "loadLocation", &luaL_loadlocation);
    lua_register(L, "isDialogExecuted", &lua_isDialogExecuted);
    lua_register(L, "getDialogName", &lua_getDialogName);
    lua_register(L, "updateCubeDialog", &lua_updateCubeDialog);
}

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

extern (C) nothrow void luaL_openmovelib(lua_State* L) {
    lua_register(L, "startCubeMove", &lua_startCubeMove);
}

extern (C) nothrow int lua_PlayMusic(lua_State *L) {
    PlayMusicStream(music);
    return 0;
}

extern (C) nothrow int lua_StopMusic(lua_State *L) {
    StopMusicStream(music);
    return 0;
}

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


extern (C) nothrow int lua_drawCube(lua_State *L) {
    Vector3 position = {
        cast(float) luaL_checknumber(L, 1),
        cast(float) luaL_checknumber(L, 2),
        cast(float) luaL_checknumber(L, 3)
    };
    return 0;
}

// Register functions in Lua
extern (C) nothrow void luaL_openaudiolib(lua_State* L) {
    lua_register(L, "loadMusic", &lua_LoadMusic);
    lua_register(L, "playMusic", &lua_PlayMusic);
    lua_register(L, "stopMusic", &lua_StopMusic);
}

extern (C) nothrow void luaL_opendrawinglib(lua_State* L) {
    lua_register(L, "addCube", &lua_addCube);
    lua_register(L, "rotateCamera", &luaL_rotateCam);
    lua_register(L, "drawCube", &lua_drawCube);
    lua_register(L, "loadScript", &luaL_loadScript);
}

extern (C) nothrow int luaL_loadScript(lua_State *L) {
    luaL_dofile(L, luaL_checkstring(L, 1));
    return 0;
}
