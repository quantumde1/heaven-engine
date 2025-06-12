#ifdef _arch_dreamcast
#include <lua/lua.h>
#include <lua/lualib.h>
#include <lua/lauxlib.h>
#else
#include <lua5.3/lua.h>
#include <lua5.3/lualib.h>
#include <lua5.3/lauxlib.h>
#endif

#include "../../include/abstraction.h"
#include "../../include/audio.h"
#include "../../include/variables.h"
#include "../../include/render_character.h"
#include "../../include/render_background.h"

#include <string.h>

int luaL_loadBackground(lua_State *L) {
    for (int i = 0; i < backgrounds.length; i++) {
        UnloadTexture(backgrounds.data[i]);
    }
    load2Dbackground((char*)luaL_checkstring(L, 1), luaL_checkinteger(L, 2));
    return 0;
}

int luaL_getTime(lua_State *L) {
    lua_pushnumber(L, GetTime());
    return 1;
}

int luaL_unloadCharacter(lua_State *L) {
    drawCharacter = false;
    UnloadTexture(characterTexture.data[luaL_checkinteger(L, 1)].texture);
    return 0;
}

int luaL_drawCharacter(lua_State *L) {
    for (int i = 0; i < characterTexture.length; i++) {
        UnloadTexture(characterTexture.data[i].texture);
    }
    load2Dcharacter((char*)luaL_checkstring(L, 1), luaL_checknumber(L, 5), luaL_checknumber(L, 4), (Vector2){luaL_checknumber(L, 2), luaL_checknumber(L, 3)});
    drawCharacter = true;
    return 0;
}

int luaL_drawBackground(lua_State *L) {
    drawBackground = true;
    drawnBackgroundIndex = luaL_checkinteger(L, 1);
    return 0;
}

int luaL_unloadBackground(lua_State *L) {
    int index = luaL_checkinteger(L, 1);
    if (index < 0 || index >= backgrounds.length || !backgrounds.data[index].id) {
        luaL_error(L, "Invalid background texture index: %d", index);
        return 0;
    }
    UnloadTexture(backgrounds.data[index]);
    backgrounds.data[index].id = 0; // Mark as unloaded
    return 0;
}

int luaL_playVideo(lua_State *L) {
    return 0;
}

int luaL_getScreenWidth(lua_State *L) {
    lua_pushinteger(L, GetScreenWidth());
    return 1;
}

int luaL_playSfx(lua_State *L) {
    printf("%s\n", "called playsfx from script");
    playSfx((char*)luaL_checkstring(L, 1));
    return 0;
}

int luaL_stopSfx(lua_State *L) {
    stopSfx();
    return 0;
}

int luaL_getScreenHeight(lua_State *L) {
    lua_pushinteger(L, GetScreenHeight());
    return 1;
}

int luaL_isDialogExecuted(lua_State *L) {
    lua_pushboolean(L, showDialog);
    return 1;
}

int luaL_dialogBox(lua_State* L)
{
    showDialog = 1;
    luaL_checktype(L, 2, LUA_TTABLE);

    dialogAnswerPage = luaL_checkinteger(L, 6);
    
    size_t textTableLength = (size_t)luaL_len(L, 2);
    pages = (char**)malloc(textTableLength * sizeof(char*));
    pagesLength = textTableLength;

    size_t answersTableLength = (size_t)luaL_len(L, 5);
    dialogAnswers = (char**)malloc(answersTableLength * sizeof(char*));
    dialogAnswerLength = answersTableLength;

    for (int i = 0; i < textTableLength; i++) {
        lua_rawgeti(L, 2, i + 1);
        const char* str = luaL_checkstring(L, -1);
        pages[i] = strdup(str);
        lua_pop(L, 1);
    }

    for (int i = 0; i < answersTableLength; i++) {
        lua_rawgeti(L, 5, i + 1);
        const char* str = luaL_checkstring(L, -1);
        dialogAnswers[i] = strdup(str);
        printf("Dialog answer is %s\n", dialogAnswers[i]);
        printf("Page is %d\n", dialogAnswerPage);
        lua_pop(L, 1);
    }

    if (lua_gettop(L) == 7)
    {
        typingSpeed = (float)luaL_checknumber(L, 7);
    }

    return 0;
}

int luaL_getAnswerValue(lua_State *L) {
    lua_pushinteger(L, dialogAnswerValue);
    return 1;
}

int luaL_loadScript(lua_State *L) {
    resetAllValues();
    luaExec = (char*)luaL_checkstring(L, 1);
    luaReload = true;
    return 0;
}

int luaL_loadMusic(lua_State *L) {
    loadMusic((char*)luaL_checkstring(L, 1));
    return 0;
}

int luaL_playMusic(lua_State *L) {
    playMusic();
    return 0;
}

int luaL_stopMusic(lua_State *L) {
    stopMusic();
    return 0;
}

int luaL_unloadMusic(lua_State *L) {
    unloadMusic();
    return 0;
}

int luaL_registration(lua_State *L) {
    lua_register(L, "loadMusic", &luaL_loadMusic);
    lua_register(L, "playVideo", &luaL_playVideo);
    lua_register(L, "playMusic", &luaL_playMusic);
    lua_register(L, "playSfx", &luaL_playSfx);
    lua_register(L, "stopSfx", &luaL_stopSfx);
    lua_register(L, "stopMusic", &luaL_stopMusic);
    lua_register(L, "unloadMusic", &luaL_unloadMusic);
    lua_register(L, "getAnswerValue", &luaL_getAnswerValue);
    lua_register(L, "load2Dtexture", &luaL_loadBackground);
    lua_register(L, "dialogBox", &luaL_dialogBox);
    lua_register(L, "getScreenWidth", &luaL_getScreenWidth);
    lua_register(L, "unload2Dtexture", &luaL_unloadBackground);
    lua_register(L, "unload2Dcharacter", &luaL_unloadCharacter);
    /* heaven compatibility */
    lua_register(L, "stopDraw2Dcharacter", &luaL_unloadCharacter);

    lua_register(L, "getScreenHeight", &luaL_getScreenHeight);
    lua_register(L, "getTime", &luaL_getTime);
    lua_register(L, "loadScript", &luaL_loadScript);
    lua_register(L, "isDialogExecuted", &luaL_isDialogExecuted);
    lua_register(L, "draw2Dtexture", &luaL_drawBackground);
    lua_register(L, "draw2Dcharacter", &luaL_drawCharacter);
    return 0;
}

void luaInit()
{
    printf("(re)loading lua");
    L = luaL_newstate();
    luaL_openlibs(L);
    luaL_registration(L);
    printf("Executing next Lua file: %s\n", luaExec);
    if (luaL_dofile(L, concat_strings(PREFIX, luaExec)) != LUA_OK)
    {
        printf("lua error\n");
        printf("%s\n", lua_tostring(L, -1));
        return;
    }
    luaReload = false;
}

void luaEventLoop()
{
    lua_getglobal(L, "EventLoop");
    if (lua_pcall(L, 0, 0, 0) != LUA_OK)
    {
        printf("error in EventLoop");
    }
    lua_pop(L, 0);
}