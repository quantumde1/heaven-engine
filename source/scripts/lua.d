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

extern (C) nothrow int lua_getAnswerValue(lua_State* L)
{
    lua_pushinteger(L, answer_num);
    return 1;
}

extern (C) nothrow int lua_loadScript(lua_State* L)
{
    for (int i = cast(int) tex2d.length; i < tex2d.length; i++)
    {
        UnloadTexture(tex2d[i].texture);
    }
    for (int i = cast(int) backgrounds.length; i < backgrounds.length; i++)
    {
        UnloadTexture(backgrounds[i]);
    }
    try
    {
        lua_exec = to!string(luaL_checkstring(L, 1));
        resetAllScriptValues();
    }
    catch (Exception e)
    {
    }
    luaReload = true;
    return 0;
}

extern (C) nothrow int lua_playVideo(lua_State* L)
{
    try
    {
        videoFinished = false;
        version (Windows)
        {
            playVideo(cast(char*) toStringz("/" ~ getcwd() ~ "/" ~ luaL_checkstring(L, 1)
                    .to!string));
        }
        version (Posix)
        {
            playVideo(cast(char*) toStringz(getcwd() ~ "/" ~ luaL_checkstring(L, 1).to!string));
        }
    }
    catch (Exception e)
    {
    }
    return 0;
}

extern (C) nothrow int luaL_dialogAnswerValue(lua_State* L)
{
    lua_pushinteger(L, answer_num); // Push the integer value onto the Lua stack
    return 1;
}

extern (C) nothrow int luaL_getButtonDialog(lua_State* L)
{
    try
    {
        if (!IsGamepadAvailable(gamepadInt))
        {
            switch (to!string(luaL_checkstring(L, 1)))
            {
            case "dialog":
                button = controlConfig.dialog_button;
                break;
            case "forward":
                button = controlConfig.forward_button;
                break;
            case "backward":
                button = controlConfig.back_button;
                break;
            case "left":
                button = controlConfig.left_button;
                break;
            case "right":
                button = controlConfig.right_button;
                break;
            case "opmenu":
                button = controlConfig.opmenu_button;
                break;
            case "buttonmap":
                button = 'P';
                break;
            default:
                break;
            }
            lua_pushstring(L, toStringz(button.to!string));
        }
        else
        {
            switch (to!string(luaL_checkstring(L, 1)))
            {
            case "dialog":
                button = GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT;
                lua_pushstring(L, toStringz("Circle/B"));
                break;
            case "forward":
                button = GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP;
                lua_pushstring(L, toStringz("Up"));
                break;
            case "backward":
                button = GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN;
                lua_pushstring(L, toStringz("Down"));
                break;
            case "left":
                button = GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP;
                lua_pushstring(L, toStringz("Left"));
                break;
            case "right":
                button = GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT;
                lua_pushstring(L, toStringz("Right"));
                break;
            case "opmenu":
                button = GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT;
                lua_pushstring(L, toStringz("Triangle/X"));
                break;
            default:
                break;
            }
        }
    }
    catch (Exception e)
    {

    }
    return 1;
}

string hint;

extern (C) nothrow int luaL_showHint(lua_State* L)
{
    hint = "" ~ to!string(luaL_checkstring(L, 1));
    hintNeeded = true;
    return 0;
}

extern (C) nothrow int luaL_isKeyPressed(lua_State* L)
{
    try
    {
        if (!IsGamepadAvailable(gamepadInt))
        {
            if (IsKeyPressed((button)))
            {
                lua_pushboolean(L, true);
            }
            else
            {
                lua_pushboolean(L, false);
            }
        }
        else
        {
            if (IsGamepadButtonPressed(gamepadInt, button.to!int))
            {
                lua_pushboolean(L, true);
            }
            else
            {
                lua_pushboolean(L, false);
            }
        }
    }
    catch (Exception e)
    {

    }
    return 1;
}

extern (C) nothrow int luaL_dialogBox(lua_State* L)
{
    showDialog = true;
    debug debug_writeln("lua called dialogbox");
    luaL_checktype(L, 2, LUA_TTABLE);

    int textTableLength = cast(int) lua_objlen(L, 2);
    message_global = new string[](textTableLength); // Allocate exact size needed

    for (int i = 0; i < textTableLength; i++)
    { // Start index from 0
        lua_rawgeti(L, 2, i + 1); // Lua indices start from 1
        message_global[i] = luaL_checkstring(L, -1).to!string;
        lua_pop(L, 1);
    }

    pageChoice_glob = cast(int) luaL_checkinteger(L, 4);
    // Get the choices array from the Lua stack
    luaL_checktype(L, 5, LUA_TTABLE);
    int choicesLength = cast(int) lua_objlen(L, 5);
    choices = new string[choicesLength];
    for (int i = 0; i < choicesLength; i++)
    {
        lua_rawgeti(L, 5, i + 1); // Lua indices start from 1
        choices[i] = luaL_checkstring(L, -1).to!string;
        lua_pop(L, 1);
    }
    if (lua_gettop(L) == 7)
    {
        typingSpeed = cast(float) luaL_checknumber(L, 7);
    }
    else
    {
        typingSpeed = 0.6f;
    }

    return 0;
}

extern (C) nothrow int lua_isDialogExecuted(lua_State *L) {
    lua_pushboolean(L, showDialog);
    return 1;
}

extern (C) nothrow int lua_load2Dbackground(lua_State* L)
{
    try
    {
        int index = cast(int) luaL_checkinteger(L, 2);

        // Если индекс выходит за границы, расширяем массив
        if (index >= backgrounds.length)
        {
            backgrounds.length = index + 1;
        }

        // Если текстура по этому индексу уже загружена, выгружаем её
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

extern (C) nothrow int lua_draw2Dbackground(lua_State* L)
{
    try
    {
        texture_background = backgrounds[luaL_checkinteger(L, 1)];
        neededDraw2D = true;
    }
    catch (Exception e)
    {
    }
    return 0;
}

extern (C) nothrow int lua_draw2Dobject(lua_State* L)
{
    try
    {
        neededCharacterDrawing = true;
        int count = cast(int) luaL_checkinteger(L, 5);

        if (count >= tex2d.length)
        {
            tex2d.length = count + 1;
        }
        tex2d[count].texture = LoadTexture(luaL_checkstring(L, 1));
        tex2d[count].x = cast(int) luaL_checkinteger(L, 2);
        tex2d[count].y = cast(int) luaL_checkinteger(L, 3);
        tex2d[count].scale = luaL_checknumber(L, 4);
    }
    catch (Exception e)
    {
    }
    return 0;
}

extern (C) nothrow int lua_loadUIAnimation(lua_State *L) {
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

extern (C) nothrow int lua_playUIAnimation(lua_State *L) {
    debug debug_writeln("Animation UI start");
    try {
        playAnimation = true;
    } catch (Exception e) {

    }
    return 0;
}

extern (C) nothrow int lua_stopUIAnimation(lua_State *L) {
    playAnimation = false;
    debug debug_writeln("Animation UI stop");
    frameDuration = 0.016f;
    currentFrame = 0;
    return 0;
}

extern (C) nothrow int lua_unloadUIAnimation(lua_State *L) {
    try {
        for (int i = 0; i < framesUI.length; i++) {
            UnloadTexture(framesUI[i]);
        }
    } catch (Exception e) {

    }
    return 0;
}

extern (C) nothrow int lua_playSfx(lua_State *L) {
    try {
    playSfx(to!string(luaL_checkstring(L, 1)));
    } catch (Exception e) {

    }
    return 0;
}

extern (C) nothrow int lua_stopDraw2Dobject(lua_State* L)
{
    for (int i = 0; i < tex2d.length; i++)
    {
        tex2d[i].texture = LoadTexture("empty");
        tex2d[i].scale = 0.0f;
        tex2d[i].x = 0;
        tex2d[i].y = 0;
    }
    int count = cast(int) luaL_checkinteger(L, 1);
    UnloadTexture(tex2d[count].texture);
    neededCharacterDrawing = false;
    return 0;
}

extern (C) nothrow int lua_getScreenWidth(lua_State* L)
{
    lua_pushinteger(L, GetScreenWidth());
    return 1;
}

extern (C) nothrow int lua_getScreenHeight(lua_State* L)
{
    lua_pushinteger(L, GetScreenHeight());
    return 1;
}

extern (C) nothrow int lua_getUsedLanguage(lua_State* L)
{
    lua_pushstring(L, usedLang.toStringz());
    return 1;
}

extern (C) nothrow int lua_stopSfx(lua_State *L) {
    StopSound(sfx);
    return 0;
}

extern (C) nothrow int lua_stop2Dbackground(lua_State* L)
{
    UnloadTexture(texture_background);
    return 0;
}

extern (C) nothrow int lua_unload2Dbackground(lua_State* L)
{
    UnloadTexture(backgrounds[cast(int) luaL_checkinteger(L, 1)]);
    return 0;
}

extern (C) nothrow int lua_2dModeEnable(lua_State* L)
{
    neededDraw2D = true;
    return 0;
}

extern (C) nothrow int lua_2dModeDisable(lua_State* L)
{
    neededDraw2D = false;
    return 0;
}

extern (C) nothrow int lua_setGameFont(lua_State* L)
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
    fontdialog = LoadFontEx(x, 40, codepoints.ptr, codepoints.length);
    return 0;
}

extern (C) nothrow int lua_getTime(lua_State* L)
{
    lua_pushnumber(L, GetTime());
    return 1;
}

extern (C) nothrow int lua_LoadMusic(lua_State* L)
{
    try
    {
        musicpath = cast(char*) luaL_checkstring(L, 1);
        music = LoadMusicStream(musicpath);
    }
    catch (Exception e)
    {
    }
    return 0;
}

// Music control functions
extern (C) nothrow int lua_PlayMusic(lua_State* L)
{
    PlayMusicStream(music);
    return 0;
}

extern (C) nothrow int lua_StopMusic(lua_State* L)
{
    StopMusicStream(music);
    return 0;
}

// Load and execute a Lua script
extern (C) nothrow int luaL_loadScript(lua_State* L)
{
    if (luaL_dofile(L, luaL_checkstring(L, 1)) != 0)
    {
        lua_pop(L, 1); // Remove error message from stack
    }
    return 0;
}

// Register the dialog functions
extern (C) nothrow void luaL_opendialoglib(lua_State* L)
{
    lua_register(L, "dialogBox", &luaL_dialogBox);
    lua_register(L, "dialogAnswerValue", &luaL_dialogAnswerValue);
    lua_register(L, "loadScript", &luaL_loadScript);
    lua_register(L, "isDialogExecuted", &lua_isDialogExecuted);
    lua_register(L, "setFont", &lua_setGameFont);
    lua_register(L, "draw2Dtexture", &lua_draw2Dbackground);
    lua_register(L, "draw2Dcharacter", &lua_draw2Dobject);
    lua_register(L, "getScreenHeight", &lua_getScreenHeight);
    lua_register(L, "playSfx", &lua_playSfx);
    lua_register(L, "loadAnimationUI", &lua_loadUIAnimation);
    lua_register(L, "playAnimationUI", &lua_playUIAnimation);
    lua_register(L, "unloadAnimationUI", &lua_unloadUIAnimation);
    lua_register(L, "loadScript", &lua_loadScript);
    lua_register(L, "getButtonName", &luaL_getButtonDialog);
    lua_register(L, "stopAnimationUI", &lua_stopUIAnimation);
    lua_register(L, "stopSfx", &lua_stopSfx);
    lua_register(L, "getScreenWidth", &lua_getScreenWidth);
    lua_register(L, "Begin2D", &lua_2dModeEnable);
    lua_register(L, "End2D", &lua_2dModeDisable);
    lua_register(L, "isKeyPressed", &luaL_isKeyPressed);
    lua_register(L, "getLanguage", &lua_getUsedLanguage);
    lua_register(L, "stopDraw2Dtexture", &lua_stop2Dbackground);
    lua_register(L, "unload2Dtexture", &lua_unload2Dbackground);
    lua_register(L, "load2Dtexture", &lua_load2Dbackground);
    lua_register(L, "playVideo", &lua_playVideo);
    lua_register(L, "loadMusic", &lua_LoadMusic);
    lua_register(L, "playMusic", &lua_PlayMusic);
    lua_register(L, "stopMusic", &lua_StopMusic);
    lua_register(L, "stopDraw2Dcharacter", &lua_stopDraw2Dobject);
    lua_register(L, "getAnswerValue", &lua_getAnswerValue);
    lua_register(L, "getTime", &lua_getTime);
}