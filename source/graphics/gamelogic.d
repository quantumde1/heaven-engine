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

void luaInit(string luaExec)
{
    debug_writeln("loading Lua");
    L = luaL_newstate();
    luaL_openlibs(L);
    luaL_loader(L);
    debug_writeln("Executing next Lua file: ", luaExec);
    if (luaL_dofile(L, toStringz(luaExec)) != LUA_OK)
    {
        debug_writeln("Lua error: ", to!string(lua_tostring(L, -1)));
        debug_writeln("Non-typical situation occured. Fix the script or contact developers.");
        return;
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
        DrawTexturePro(backgroundTexture, Rectangle(0, 0, cast(float) backgroundTexture.width, cast(
                float) backgroundTexture.height), Rectangle(0, 0, cast(float) GetScreenWidth(), cast(
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
        displayDialog(messageGlobal, pageChoice_glob, textFont, &showDialog, typingSpeed);
    }
}