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
import std.string;
import std.math;
import dialogs.dialog_system;

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
    luaL_opendialoglib(L);
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
    UpdateMusicStream(music);
    if (neededDraw2D)
    {
        DrawTexturePro(texture_background, Rectangle(0, 0, cast(float) texture_background.width, cast(
                float) texture_background.height), Rectangle(0, 0, cast(float) GetScreenWidth(), cast(
                float) GetScreenHeight()), Vector2(0, 0), 0.0, Colors.WHITE);
    }
    if (neededCharacterDrawing)
    {
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
    playUIAnimation(framesUI);
    if (showDialog) {
        displayDialog(message_global, pageChoice_glob, fontdialog, &showDialog, typingSpeed);
    }
}