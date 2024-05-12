module scripts.lua_engine;

import bindbc.lua;
import raylib;

import graphics.main_cycle;
import std.stdio;
import std.conv;
import graphics.cubes;

Music music;

extern (C) nothrow int lua_LoadMusic(lua_State *L) {
    auto musicPath = luaL_checkstring(L, 1);
    music = LoadMusicStream(musicPath);
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
    int textTableLength = luaL_len(L, 5);
    string[] textPages = new string[](textTableLength); 
    for (int i = 1; i <= textTableLength; i++) {
        lua_rawgeti(L, 5, i);
        textPages[i - 1] = luaL_checkstring(L, -1).to!string;
        lua_pop(L, 1);
    }

    addCube(position, name.to!string, textPages, emotion);
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

extern (C) nothrow void luaL_openaudiolib(lua_State* L) {
    lua_register(L, "loadMusic", &lua_LoadMusic);
    lua_register(L, "playMusic", &lua_PlayMusic);
    lua_register(L, "stopMusic", &lua_StopMusic);
}

extern (C) nothrow void luaL_opendrawinglib(lua_State* L) {
    lua_register(L, "addCube", &lua_addCube);
    lua_register(L, "drawCube", &lua_drawCube);
}

void lua_loader() {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    luaL_opendrawinglib(L);
    luaL_openaudiolib(L);
    luaL_openmovelib(L);
    if (luaL_dofile(L, "scripts/00_script.lua") != LUA_OK) {
        writeln("Lua error: ", lua_tostring(L, -1));
        lua_pop(L, 1);
    }
}