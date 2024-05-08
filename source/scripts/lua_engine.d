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
    auto text = luaL_checkstring(L, 5);
    Vector3 position = {
        cast(float) luaL_checknumber(L, 1),
        cast(float) luaL_checknumber(L, 2),
        cast(float) luaL_checknumber(L, 3)
    };
    int emotion = cast(int) luaL_checkinteger(L, 6);
    
    addCube(position, name.to!string, text.to!string, emotion);
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