// quantumde1 developed software, licensed under BSD-0-Clause license.
module scripts.lua;

import bindbc.lua;
import raylib;
import variables;
import graphics.effects;
import std.conv;
import scripts.config;
import std.string;
import graphics.engine;
import graphics.playback;
import std.file;
import std.array;
import std.algorithm;

/* 
 * This module provides Lua bindings for various engine functionalities.
 * Functions are built on top of engine built-in functions for execution from scripts.
 * Not all engine functions usable for scripting are yet implemented.
*/

string hint;

extern (C) nothrow int luaL_showHint(lua_State* L)
{
    hint = "" ~ to!string(luaL_checkstring(L, 1));
    hintNeeded = true;
    return 0;
}

/* text window */

extern (C) nothrow int luaL_dialogBox(lua_State* L)
{
    showDialog = true;
    luaL_checktype(L, 2, LUA_TTABLE);
    choicePage = cast(int)luaL_checkinteger(L, 4);
    
    int textTableLength = cast(int) lua_objlen(L, 2);
    messageGlobal = new string[](textTableLength); 

    for (int i = 0; i < textTableLength; i++) {
        lua_rawgeti(L, 2, i + 1);
        messageGlobal[i] = luaL_checkstring(L, -1).to!string;
        lua_pop(L, 1);
    }

    luaL_checktype(L, 5, LUA_TTABLE);
    int choicesLength = cast(int) lua_objlen(L, 5);
    choices = new string[choicesLength];
    for (int i = 0; i < choicesLength; i++)
    {
        lua_rawgeti(L, 5, i + 1);
        choices[i] = luaL_checkstring(L, -1).to!string;
        lua_pop(L, 1);
    }
    if (lua_gettop(L) == 7)
    {
        typingSpeed = cast(float) luaL_checknumber(L, 7);
    }

    return 0;
}

extern (C) nothrow int luaL_getAnswerValue(lua_State* L)
{
    lua_pushinteger(L, selectedChoice);
    return 1;
}

extern (C) nothrow int luaL_isDialogExecuted(lua_State *L) {
    lua_pushboolean(L, showDialog);
    return 1;
}

extern (C) nothrow int luaL_dialogAnswerValue(lua_State* L)
{
    lua_pushinteger(L, selectedChoice);
    return 1;
}

/* background drawing and loading */

extern (C) nothrow int luaL_load2Dbackground(lua_State* L)
{
    try
    {
        int index = cast(int) luaL_checkinteger(L, 2);
        //if index too big, extending array
        if (index >= backgrounds.length)
        {
            backgrounds.length = index + 1;
        }

        // if texture with same Index already loaded, unloading it
        if (index < backgrounds.length && backgrounds[index].id != 0)
        {
            UnloadTexture(backgrounds[index]);
        }
        backgrounds[index] = LoadTexture(luaL_checkstring(L, 1));
    }
    catch (Exception e)
    {
    }
    return 0;
}

extern (C) nothrow int luaL_draw2Dbackground(lua_State* L)
{
    try
    {
        backgroundTexture = backgrounds[luaL_checkinteger(L, 1)];
        neededDraw2D = true;
    }
    catch (Exception e)
    {
    }
    return 0;
}

extern (C) nothrow int luaL_unload2Dbackground(lua_State* L)
{
    UnloadTexture(backgrounds[cast(int) luaL_checkinteger(L, 1)]);
    return 0;
}

/* character textures */

extern (C) nothrow int luaL_draw2Dcharacter(lua_State* L)
{
    try
    {
        int count = cast(int) luaL_checkinteger(L, 5);

        if (count >= characterTextures.length)
        {
            characterTextures.length = count + 1;
        }
        characterTextures[count].texture = LoadTexture(luaL_checkstring(L, 1));
        characterTextures[count].x = cast(int) luaL_checkinteger(L, 2);
        characterTextures[count].y = cast(int) luaL_checkinteger(L, 3);
        characterTextures[count].scale = luaL_checknumber(L, 4);
        characterTextures[count].width = characterTextures[count].texture.width;
        characterTextures[count].height = characterTextures[count].texture.height;

        neededCharacterDrawing = true;
    }
    catch (Exception e)
    {
    }
    return 0;
}

extern (C) nothrow int luaL_stopDraw2Dcharacter(lua_State* L)
{
    int count = cast(int) luaL_checkinteger(L, 1);
    UnloadTexture(characterTextures[count].texture);
    neededCharacterDrawing = false;
    return 0;
}

/* music and video */

extern (C) nothrow int luaL_LoadMusic(lua_State* L)
{
    try
    {
        musicPath = cast(char*) luaL_checkstring(L, 1);
        music = LoadMusicStream(musicPath);
    }
    catch (Exception e)
    {
    }
    return 0;
}

extern (C) nothrow int luaL_PlayMusic(lua_State* L)
{
    PlayMusicStream(music);
    return 0;
}

extern (C) nothrow int luaL_StopMusic(lua_State* L)
{
    StopMusicStream(music);
    return 0;
}

extern (C) nothrow int luaL_playSfx(lua_State *L) {
    try {
    playSfx(to!string(luaL_checkstring(L, 1)));
    } catch (Exception e) {

    }
    return 0;
}

extern (C) nothrow int luaL_stopSfx(lua_State *L) {
    StopSound(sfx);
    return 0;
}


extern (C) nothrow int luaL_playVideo(lua_State* L)
{
    try
    {
        videoFinished = false;
        playVideo(luaL_checkstring(L, 1).to!string);
    }
    catch (Exception e)
    {
    }
    return 0;
}

/* ui animations */

extern (C) nothrow int luaL_loadUIAnimation(lua_State *L) {
    try {
    framesUI = loadAnimationFramesUI("res/uifx/"~to!string(luaL_checkstring(L, 1)), to!string(luaL_checkstring(L, 2)));
    if (lua_gettop(L) == 3) {
        frameDuration = luaL_checknumber(L, 3);
        debug debug_writeln("frameDuration: ", frameDuration);
    }
    } catch (Exception e) {
    }
    return 0;
}

extern (C) nothrow int luaL_playUIAnimation(lua_State *L) {
    debug debug_writeln("Animation UI start");
    try {
        playAnimation = true;
    } catch (Exception e) {

    }
    return 0;
}

extern (C) nothrow int luaL_stopUIAnimation(lua_State *L) {
    playAnimation = false;
    debug debug_writeln("Animation UI stop");
    frameDuration = 0.016f;
    currentFrame = 0;
    return 0;
}

extern (C) nothrow int luaL_unloadUIAnimation(lua_State *L) {
    try {
        for (int i = 0; i < framesUI.length; i++) {
            UnloadTexture(framesUI[i]);
        }
    } catch (Exception e) {

    }
    return 0;
}

/* system */

extern (C) nothrow int luaL_getScreenWidth(lua_State* L)
{
    lua_pushinteger(L, GetScreenWidth());
    return 1;
}

extern (C) nothrow int luaL_getScreenHeight(lua_State* L)
{
    lua_pushinteger(L, GetScreenHeight());
    return 1;
}

extern (C) nothrow int luaL_getUsedLanguage(lua_State* L)
{
    lua_pushstring(L, usedLang.toStringz());
    return 1;
}

extern (C) nothrow int luaL_2dModeEnable(lua_State* L)
{
    neededDraw2D = true;
    return 0;
}

extern (C) nothrow int luaL_2dModeDisable(lua_State* L)
{
    neededDraw2D = false;
    return 0;
}

extern (C) nothrow int luaL_setGameFont(lua_State* L)
{
    const char* x = luaL_checkstring(L, 1);
    debug_writeln("Setting custom font: ", x.to!string);
    int[512] codepoints = 0;
    foreach (i; 0 .. 95)
    {
        codepoints[i] = 32 + i;
    }
    foreach (i; 0 .. 255)
    {
        codepoints[96 + i] = 0x400 + i;
    }
    textFont = LoadFontEx(x, 40, codepoints.ptr, codepoints.length);
    return 0;
}

extern (C) nothrow int luaL_getTime(lua_State* L)
{
    lua_pushnumber(L, GetTime());
    return 1;
}

extern (C) nothrow int luaL_isKeyPressed(lua_State* L)
{
    try
    {
        if (IsKeyPressed(cast(int)(luaL_checkinteger(L, 1))))
        {
            lua_pushboolean(L, true);
        }
        else
        {
            lua_pushboolean(L, false);
        }
    }
    catch (Exception e)
    {

    }
    return 1;
}

extern (C) nothrow int luaL_loadScript(lua_State* L)
{
    for (int i = cast(int) characterTextures.length; i < characterTextures.length; i++)
    {
        UnloadTexture(characterTextures[i].texture);
    }
    for (int i = cast(int) backgrounds.length; i < backgrounds.length; i++)
    {
        UnloadTexture(backgrounds[i]);
    }
    try
    {
        luaExec = to!string(luaL_checkstring(L, 1));
        resetAllScriptValues();
    }
    catch (Exception e)
    {
    }
    luaReload = true;
    return 0;
}

/* Register functions */

extern (C) nothrow void luaL_loader(lua_State* L)
{
    lua_register(L, "dialogBox", &luaL_dialogBox);
    lua_register(L, "dialogAnswerValue", &luaL_dialogAnswerValue);
    lua_register(L, "isDialogExecuted", &luaL_isDialogExecuted);
    lua_register(L, "getAnswerValue", &luaL_getAnswerValue);
    lua_register(L, "loadAnimationUI", &luaL_loadUIAnimation);
    lua_register(L, "playAnimationUI", &luaL_playUIAnimation);
    lua_register(L, "stopAnimationUI", &luaL_stopUIAnimation);
    lua_register(L, "unloadAnimationUI", &luaL_unloadUIAnimation);
    lua_register(L, "playVideo", &luaL_playVideo);
    lua_register(L, "loadMusic", &luaL_LoadMusic);
    lua_register(L, "playMusic", &luaL_PlayMusic);
    lua_register(L, "stopMusic", &luaL_StopMusic);
    lua_register(L, "playSfx", &luaL_playSfx);
    lua_register(L, "stopSfx", &luaL_stopSfx);
    lua_register(L, "Begin2D", &luaL_2dModeEnable);
    lua_register(L, "End2D", &luaL_2dModeDisable);
    lua_register(L, "draw2Dcharacter", &luaL_draw2Dcharacter);
    lua_register(L, "stopDraw2Dcharacter", &luaL_stopDraw2Dcharacter);
    lua_register(L, "load2Dtexture", &luaL_load2Dbackground);
    lua_register(L, "draw2Dtexture", &luaL_draw2Dbackground);
    lua_register(L, "unload2Dtexture", &luaL_unload2Dbackground);
    lua_register(L, "getTime", &luaL_getTime);
    lua_register(L, "loadScript", &luaL_loadScript);
    lua_register(L, "setFont", &luaL_setGameFont);
    lua_register(L, "getScreenHeight", &luaL_getScreenHeight);
    lua_register(L, "getScreenWidth", &luaL_getScreenWidth);
    lua_register(L, "isKeyPressed", &luaL_isKeyPressed);
    lua_register(L, "getLanguage", &luaL_getUsedLanguage);
}