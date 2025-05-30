// quantumde1 developed software, licensed under BSD-0-Clause license.
module scripts.lua;

import bindbc.lua;
import raylib;
import variables;
import std.stdio;
import graphics.effects;
import std.conv;
import scripts.config;
import graphics.cubes;
import std.string;
import graphics.engine;
import graphics.scene;
import graphics.battle;
import graphics.video;
import std.file;
import graphics.map;
import std.array;
import std.algorithm;
import core.thread;

/* 
 * This module provides Lua bindings for various engine functionalities.
 * Functions are built on top of engine built-in functions for execution from scripts.
 * Not all engine functions usable for scripting are yet implemented.
*/

extern (C) nothrow int lua_initBattle(lua_State* L)
{
    int isBoss = cast(int) luaL_checkinteger(L, 1);
    //demonsBossfightAllowed ~= to!string(cast(char*)luaL_checkstring(L, 3));
    luaL_checktype(L, 2, LUA_TTABLE);
    int choicesLength = cast(int) lua_objlen(L, 2);
    demonsBossfightAllowed = new string[choicesLength];
    for (int i = 0; i < choicesLength; i++)
    {
        lua_rawgeti(L, 2, i + 1); // Lua indices start from 1
        demonsBossfightAllowed[i] = luaL_checkstring(L, -1).to!string;
        lua_pop(L, 1);
    }
    randomNumber = choicesLength;
    try
    {
        isBossfight = isBoss.to!bool;
    }
    catch (Exception e)
    {
    }
    playerStepCounter = encounterThreshold + 1;
    return 0;
}

extern (C) nothrow lua_getBattleStatus(lua_State* L)
{
    //status mean ended or not
    lua_pushboolean(L, inBattle);
    return 1;
}

extern (C) nothrow lua_setRotationCrowler(lua_State* L)
{
    if (luaL_checkinteger(L, 1) == 1)
    {
        dungeonCrawlerMode = 1;
    }
    else if (luaL_checkinteger(L, 1) == 0)
    {
        dungeonCrawlerMode = 0;
    }
    return 0;
}

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
    for (int i = cast(int) floorModel.length; i < floorModel.length; i++)
    {
        UnloadModel(floorModel[i]);
    }
    for (int i = cast(int) cubeModels.length; i < cubeModels.length; i++)
    {
        UnloadModel(cubeModels[i]);
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

// Lua State Functions
extern (C) nothrow int lua_isDialogExecuted(lua_State* L)
{
    lua_pushboolean(L, event_initialized);
    return 1; // Number of return values
}

extern (C) nothrow int lua_setFriendlyZone(lua_State* L)
{
    if (luaL_checkinteger(L, 1) == 0)
    {
        friendlyZone = false;
    }
    if (luaL_checkinteger(L, 1) == 1)
    {
        friendlyZone = true;
    }
    return 0;
}

char* fragment;
char* vertex;

extern (C) nothrow int lua_reloadShaderVertex(lua_State* L)
{
    UnloadShader(shader);
    vertex = cast(char*) luaL_checkstring(L, 1);
    shader = LoadShader(vertex, fragment);
    shadersReload = 1;
    return 0;
}

extern (C) nothrow int lua_reloadShaderFragment(lua_State* L)
{
    UnloadShader(shader);
    fragment = cast(char*) luaL_checkstring(L, 1);
    shader = LoadShader(vertex, fragment);
    shadersReload = 1;
    return 0;
}

extern (C) nothrow int lua_removeCube(lua_State* L)
{
    try
    {
        debug
        {
            debug_writeln("Removing: ", to!string(luaL_checkstring(L, 1)));
        }
        removeCube(to!string(luaL_checkstring(L, 1)));
    }
    catch (Exception e)
    {
    }
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

extern (C) nothrow int lua_allowControl(lua_State* L)
{
    allowControl = true;
    return 0;
}

extern (C) nothrow int lua_disallowControl(lua_State* L)
{
    allowControl = false;
    return 0;
}

extern (C) nothrow int lua_changeCameraPosition(lua_State* L)
{
    positionCam = Vector3(
        luaL_checknumber(L, 1),
        luaL_checknumber(L, 2),
        luaL_checknumber(L, 3)
    );
    updateCamera = true;
    return 0;
}

extern (C) nothrow int lua_resetCameraState(lua_State* L)
{
    upCam = oldCamera.up;
    targetCam = oldCamera.target;
    positionCam = oldCamera.position;
    updateCamera = true;
    return 0;
}

extern (C) nothrow int lua_saveCameraState(lua_State* L)
{
    oldCamera = camera;
    return 0;
}

extern (C) nothrow int lua_changeCameraUp(lua_State* L)
{
    upCam = Vector3(
        luaL_checknumber(L, 1),
        luaL_checknumber(L, 2),
        luaL_checknumber(L, 3)
    );
    updateCamera = true;
    return 0;
}

extern (C) nothrow int lua_disableAnimations(lua_State* L)
{
    animations = cast(int) luaL_checkinteger(L, 1);
    return 0;
}

extern (C) nothrow int lua_changeCameraTarget(lua_State* L)
{
    targetCam = Vector3(
        luaL_checknumber(L, 1),
        luaL_checknumber(L, 2),
        luaL_checknumber(L, 3)
    );
    updateCamera = true;
    return 0;
}

extern (C) nothrow int lua_drawPlayerModel(lua_State* L)
{
    if (luaL_checkinteger(L, 1) == 0)
    {
        drawPlayer = false;
    }
    if (luaL_checkinteger(L, 1) == 1)
    {
        drawPlayer = true;
    }
    return 0;
}

extern (C) nothrow int lua_getDialogName(lua_State* L)
{
    lua_pushstring(L, name_global.toStringz());
    return 1; // Number of return values
}

extern (C) nothrow int luaL_dialogAnswerValue(lua_State* L)
{
    lua_pushinteger(L, answer_num); // Push the integer value onto the Lua stack
    return 1;
}

extern (C) nothrow int lua_parseScene(lua_State* L)
{
    try
    {
        light_pos = [];
        lights = [];
        parseSceneFile(luaL_checkstring(L, 1).to!string);
        shadersReload = 1;
    }
    catch (Exception e)
    {

    }
    return 0;
}

extern (C) nothrow int lua_getOldCameraAngle(lua_State* L)
{
    lua_pushnumber(L, oldDegree);
    return 1;
}

extern (C) nothrow int luaL_rotateCam(lua_State* L)
{
    isCameraRotating = true;
    iShowSpeed = luaL_checknumber(L, 2);
    neededDegree = luaL_checknumber(L, 1);
    return 0;
}

extern (C) nothrow int luaL_rotateCamState(lua_State* L)
{
    lua_pushboolean(L, isCameraRotating);
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

extern (C) nothrow int luaL_hideHint(lua_State* L)
{
    hintNeeded = false;
    return 0;
}

extern (C) nothrow int luaL_hideUI(lua_State* L)
{
    hideNavigation = true;
    return 0;
}

extern (C) nothrow int luaL_showUI(lua_State* L)
{
    hideNavigation = false;
    return 0;
}

extern (C) nothrow int luaL_openMap(lua_State* L)
{
    StopMusicStream(music);
    import graphics.map;

    try
    {
        openMap(to!string(luaL_checkstring(L, 1)), true);
    }
    catch (Exception e)
    {
        debug
        {
            debug_writeln("Error opening map.");
        }
    }
    return 0;
}

extern (C) nothrow int luaL_dialogBox(lua_State* L)
{
    name_global = luaL_checkstring(L, 1).to!string; // Update dialog name
    event_initialized = true;
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
    emotion_global = cast(char*) luaL_checkstring(L, 3);
    try
    {
        uint image_size;
        char* image_data = get_file_data_from_archive("res/faces.bin", emotion_global, &image_size);
        dialogImage = LoadTextureFromImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*) image_data, image_size));
        UnloadImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*) image_data, image_size));
    }
    catch (Exception e)
    {
    }
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
    int x_pos = cast(int) luaL_checkinteger(L, 6);
    if (x_pos == 0)
    {
        pos = false;
    }
    if (x_pos == 1)
    {
        pos = true;
    }
    if (lua_gettop(L) == 7)
    {
        typingSpeed = cast(float) luaL_checknumber(L, 7);
    }
    else
    {
        typingSpeed = 0.018f;
    }
    showDialog = true;
    allowControl = false;
    show_sec_dialog = true;

    return 0;
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

        uint image_size;
        char* image_data = get_file_data_from_archive("res/bg.bin", luaL_checkstring(L, 1), &image_size);
        backgrounds[index] = LoadTextureFromImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*) image_data, image_size));
        UnloadImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*) image_data, image_size));
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

        uint image_size;
        char* image_data = get_file_data_from_archive("res/tex.bin", luaL_checkstring(L, 1), &image_size);
        Image img = LoadImageFromMemory(".PNG", cast(const(ubyte)*) image_data, image_size);
        tex2d[count].texture = LoadTextureFromImage(img);
        // Store the texture dimensions
        tex2d[count].width = img.width;
        tex2d[count].height = img.height;
        UnloadImage(img);
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

extern (C) nothrow int lua_getLocationName(lua_State* L)
{
    lua_pushstring(L, cast(char*) locationname);
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

extern (C) nothrow int lua_updateCubeDialog(lua_State* L)
{
    auto name = luaL_checkstring(L, 1).to!string;
    luaL_checktype(L, 2, LUA_TTABLE);

    bool cubeFound = false;

    // Update the cube dialog text
    foreach (ref cube; cubes)
    {
        if (cube.name == name)
        {
            int textTableLength = cast(int) lua_objlen(L, 2);
            cube.text = new string[](textTableLength);
            for (int i = 1; i <= textTableLength; i++)
            {
                lua_rawgeti(L, 2, i);
                cube.text[i - 1] = luaL_checkstring(L, -1).to!string;
                lua_pop(L, 1);
            }
            cubeFound = true;
            break;
        }
    }

    // If cube with the given name is not found, raise an error
    try
    {
        if (!cubeFound)
        {
            debug_writeln("Error: Cube not found: ", name);
        }
    }
    catch (Exception e)
    {

    }
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

extern (C) nothrow int lua_shadersState(lua_State* L)
{
    shaderEnabled = cast(bool) luaL_checkinteger(L, 1);
    return 0;
}

extern (C) nothrow int lua_getTime(lua_State* L)
{
    lua_pushnumber(L, GetTime());
    return 1;
}

// Register the dialog functions
extern (C) nothrow void luaL_opendialoglib(lua_State* L)
{
    lua_register(L, "dialogBox", &luaL_dialogBox);
    lua_register(L, "shadersState", &lua_shadersState);
    lua_register(L, "dialogAnswerValue", &luaL_dialogAnswerValue);
    //lua_register(L, "loadLocation", &luaL_loadlocation);
    lua_register(L, "getLocationName", &lua_getLocationName);
    lua_register(L, "initBattle", &lua_initBattle);
    lua_register(L, "isDialogExecuted", &lua_isDialogExecuted);
    lua_register(L, "getBattleStatus", &lua_getBattleStatus);
    lua_register(L, "getDialogName", &lua_getDialogName);
    lua_register(L, "showHint", &luaL_showHint);
    lua_register(L, "hideHint", &luaL_hideHint);
    lua_register(L, "showUI", &luaL_showUI);
    lua_register(L, "dungeonCrawlerMode", &lua_setRotationCrowler);
    lua_register(L, "updateCubeDialog", &lua_updateCubeDialog);
    lua_register(L, "setFont", &lua_setGameFont);
    lua_register(L, "draw2Dtexture", &lua_draw2Dbackground);
    lua_register(L, "animationsState", &lua_disableAnimations);
    lua_register(L, "draw2Dcharacter", &lua_draw2Dobject);
    lua_register(L, "getScreenHeight", &lua_getScreenHeight);
    lua_register(L, "playSfx", &lua_playSfx);
    lua_register(L, "loadAnimationUI", &lua_loadUIAnimation);
    lua_register(L, "playAnimationUI", &lua_playUIAnimation);
    lua_register(L, "unloadAnimationUI", &lua_unloadUIAnimation);
    lua_register(L, "loadScript", &lua_loadScript);
    lua_register(L, "saveCameraState", &lua_saveCameraState);
    lua_register(L, "resetCameraState", &lua_resetCameraState);
    lua_register(L, "getButtonName", &luaL_getButtonDialog);
    lua_register(L, "reloadShaderVertex", &lua_reloadShaderVertex);
    lua_register(L, "stopAnimationUI", &lua_stopUIAnimation);
    lua_register(L, "stopSfx", &lua_stopSfx);
    lua_register(L, "getScreenWidth", &lua_getScreenWidth);
    lua_register(L, "reloadShaderFragment", &lua_reloadShaderFragment);
    lua_register(L, "Begin2D", &lua_2dModeEnable);
    lua_register(L, "End2D", &lua_2dModeDisable);
    lua_register(L, "isKeyPressed", &luaL_isKeyPressed);
    lua_register(L, "getLanguage", &lua_getUsedLanguage);
    lua_register(L, "stopDraw2Dtexture", &lua_stop2Dbackground);
    lua_register(L, "unload2Dtexture", &lua_unload2Dbackground);
    lua_register(L, "load2Dtexture", &lua_load2Dbackground);
    lua_register(L, "playVideo", &lua_playVideo);
    lua_register(L, "isCameraRotating", &luaL_rotateCamState);
    lua_register(L, "allowControl", &lua_allowControl);
    lua_register(L, "disallowControl", &lua_disallowControl);
    lua_register(L, "drawPlayerModel", &lua_drawPlayerModel);
    lua_register(L, "loadScene", &lua_parseScene);
    lua_register(L, "getAnswerValue", &lua_getAnswerValue);
    lua_register(L, "getTime", &lua_getTime);
    lua_register(L, "getOldCameraAngle", &lua_getOldCameraAngle);
}

// Music functions
extern (C) nothrow int lua_LoadMusic(lua_State* L)
{
    try
    {
        musicpath = cast(char*) luaL_checkstring(L, 1);
        uint audio_size;
        char* audio_data = get_file_data_from_archive("res/data.bin", musicpath, &audio_size);

        if (audioEnabled)
        {
            UnloadMusicStream(music);
            music = LoadMusicStreamFromMemory(".mp3", cast(const(ubyte)*) audio_data, audio_size);
        }
    }
    catch (Exception e)
    {
    }
    return 0;
}

extern (C) nothrow int lua_LoadMusicExternal(lua_State* L)
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

extern (C) nothrow int lua_startCubeRotation(lua_State* L)
{
    try
    {
        cubeIndex = cast(int) luaL_checkinteger(L, 1) - 1;
        targetAngle = cast(float) luaL_checknumber(L, 2);
        targetSpeed = cast(float) luaL_checknumber(L, 3);
        duration = cast(float) luaL_checknumber(L, 4);
        if (cubeIndex >= 0 && cubeIndex < cubes.length)
        {
            rotateCube(cubes[cubeIndex], targetAngle, targetSpeed, duration);
        }
        else
        {
            luaL_error(L, "Invalid cube index");
        }
    }
    catch (Exception e)
    {

    }
    return 0;
}

extern (C) nothrow int lua_startCubeMove(lua_State* L)
{
    int cubeIndex = cast(int) luaL_checkinteger(L, 1) - 1;
    Vector3 endPosition = {
        cast(float) luaL_checknumber(L, 2),
        cast(float) luaL_checknumber(L, 3),
        cast(float) luaL_checknumber(L, 4)
    };
    float duration = cast(float) luaL_checknumber(L, 5);
    if (cubeIndex >= 0 && cubeIndex < cubes.length)
    {
        startCubeMove(cubes[cubeIndex], endPosition, duration);
    }
    else
    {
        luaL_error(L, "Invalid cube index");
    }
    return 0;
}

// Register the movement functions
extern (C) nothrow void luaL_openmovelib(lua_State* L)
{
    lua_register(L, "startCubeMove", &lua_startCubeMove);
    lua_register(L, "startCubeRotation", &lua_startCubeRotation);
    lua_register(L, "changeCameraUp", &lua_changeCameraUp);
    lua_register(L, "stopDraw2Dcharacter", &lua_stopDraw2Dobject);
    lua_register(L, "setFriendlyZone", &lua_setFriendlyZone);
    lua_register(L, "changeCameraTarget", &lua_changeCameraTarget);
    lua_register(L, "changeCameraPosition", &lua_changeCameraPosition);
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

extern (C) nothrow int lua_getPlayerXPos(lua_State* L)
{
    lua_pushnumber(L, cast(int) cubePosition.x);
    return 1;
}

extern (C) nothrow int lua_getPlayerYPos(lua_State* L)
{
    lua_pushnumber(L, cast(int) cubePosition.y);
    return 1;
}

extern (C) nothrow int lua_getPlayerZPos(lua_State* L)
{
    lua_pushnumber(L, cast(int) cubePosition.z);
    return 1;
}

extern (C) nothrow int lua_setPlayerXYZPos(lua_State* L)
{
    cubePosition = Vector3(luaL_checknumber(L, 1), luaL_checknumber(L, 2), luaL_checknumber(L, 3));
    return 1;
}

extern (C) nothrow int lua_getCubeXPos(lua_State* L)
{
    lua_pushnumber(L, cubes[luaL_checkinteger(L, 1) - 1].boundingBox.min.x);
    return 1;
}

extern (C) nothrow int lua_getCubeYPos(lua_State* L)
{
    lua_pushnumber(L, cubes[luaL_checkinteger(L, 1) - 1].boundingBox.min.y);
    return 1;
}

extern (C) nothrow int lua_getCubeZPos(lua_State* L)
{
    lua_pushnumber(L, cubes[luaL_checkinteger(L, 1) - 1].boundingBox.min.z);
    return 1;
}

extern (C) nothrow int lua_getCameraXPos(lua_State* L)
{
    lua_pushnumber(L, positionCam.x);
    return 1;
}

extern (C) nothrow int lua_getCameraYPos(lua_State* L)
{
    lua_pushnumber(L, positionCam.y);
    return 1;
}

extern (C) nothrow int lua_getCameraZPos(lua_State* L)
{
    lua_pushnumber(L, positionCam.z);
    return 1;
}

// Cube management functions
extern (C) nothrow int lua_addCube(lua_State* L)
{
    auto name = luaL_checkstring(L, 4);
    char* emotion = cast(char*) luaL_checkstring(L, 6);
    Vector3 position = {
        cast(float) luaL_checknumber(L, 1),
        cast(float) luaL_checknumber(L, 2),
        cast(float) luaL_checknumber(L, 3)
    };

    luaL_checktype(L, 5, LUA_TTABLE);
    int textTableLength = cast(int) lua_objlen(L, 5);
    string[] textPages = new string[](textTableLength);

    for (int i = 1; i <= textTableLength; i++)
    {
        lua_rawgeti(L, 5, i);
        textPages[i - 1] = luaL_checkstring(L, -1).to!string;
        lua_pop(L, 1);
    }
    int choicePage = cast(int) luaL_checkinteger(L, 7);
    addCube(position, name.to!string, textPages, emotion, choicePage);
    return 0;
}

extern (C) nothrow int lua_fixCameraPosition(lua_State* L)
{
    return 0;
}

extern (C) nothrow int lua_setMcModel(lua_State* L)
{
    playerModelName = cast(char*)(luaL_checkstring(L, 1));

    playerModel = LoadModel(luaL_checkstring(L, 1));
    modelCharacterSize = Vector3(luaL_checknumber(L, 2), luaL_checknumber(L, 3), luaL_checknumber(L, 4));
    return 0;
}

extern (C) nothrow int lua_setPlayerSize(lua_State* L)
{
    modelCharacterSize = Vector3(luaL_checknumber(L, 1), luaL_checknumber(L, 2), luaL_checknumber(L, 3));
    return 0;
}

extern (C) nothrow int lua_setPlayerCollisionSize(lua_State* L)
{
    float width = luaL_checknumber(L, 1);
    float height = luaL_checknumber(L, 2);
    float depth = luaL_checknumber(L, 3);

    collisionCharacterSize = Vector3(width, height * 2, depth);

    return 0;
}

extern (C) nothrow int lua_allowDemons(lua_State* L)
{
    luaL_checktype(L, 1, LUA_TTABLE);
    int textTableLength = cast(int) lua_objlen(L, 1);
    demonsAllowed = new string[](textTableLength);
    for (int i = 1; i <= textTableLength; i++)
    {
        lua_rawgeti(L, 1, i);
        demonsAllowed[i - 1] = luaL_checkstring(L, -1).to!string;
        lua_pop(L, 1);
    }
    return 0;
}

extern (C) nothrow int lua_setCubeModel(lua_State* L)
{
    int index = cast(int) luaL_checkinteger(L, 1) - 1;
    const char* modelPath = luaL_checkstring(L, 2);
    modelCubeSize = luaL_checknumber(L, 3);
    cubeModels[index] = LoadModel(modelPath);
    return 0;
}

extern (C) nothrow int lua_removeCubeModel(lua_State* L)
{
    int index = cast(int) luaL_checkinteger(L, 1) - 1;
    cubeModels = cubeModels[0 .. index] ~ cubeModels[index + 1 .. cubeModels.length];
    return 0;
}

extern (C) nothrow int lua_howMuchModels(lua_State* L)
{
    int index = cast(int) luaL_checkinteger(L, 1);
    cubeModels = new Model[index];
    return 0;
}

extern (C) nothrow int lua_cubeMoveStatus(lua_State* L)
{
    try
    {
        lua_pushboolean(L, isAnyCubeMoving());
    }
    catch (Exception e)
    {
    }
    return 1;
}

import ui.inventory;

extern (C) nothrow int lua_checkObjectInInventory(lua_State* L)
{
    try
    {
        debug_writeln("Searching object in inventory...");
        string target = to!string(luaL_checkstring(L, 1));
        bool found = canFind(buttonTextsInventory[to!int(luaL_checkinteger(L, 2))], target);
        lua_pushboolean(L, found);
    }
    catch (Exception e)
    {

    }
    return 1;
}

extern (C) nothrow int lua_setButtonLogic(lua_State* L)
{
    if (luaL_checkstring(L, 1) == cast(char*) "exit")
    {
    }
    return 0;
}

extern (C) nothrow int lua_configureInventoryTabs(lua_State* L)
{
    try
    {
        int textTableLength = cast(int) lua_objlen(L, 1);
        string[] tabsNames = new string[](textTableLength); // Allocate exact size needed

        for (int i = 0; i < textTableLength; i++)
        { // Start index from 0
            lua_rawgeti(L, 1, i + 1); // Lua indices start from 1
            tabsNames[i] = luaL_checkstring(L, -1).to!string;
            lua_pop(L, 1);
        }
        configureTabs(tabsNames);
    }
    catch (Exception e)
    {

    }
    return 0;
}

extern (C) nothrow int lua_addToInventoryTab(lua_State* L)
{
    try
    {
        addToTab(to!string(luaL_checkstring(L, 1)), to!int(luaL_checkinteger(L, 2)));
    }
    catch (Exception e)
    {

    }
    return 0;
}

extern (C) nothrow int lua_setCameraRotationSpeed(lua_State* L)
{
    rotationStep = luaL_checknumber(L, 1);
    return 0;
}

extern (C) nothrow int lua_addPartyMember(lua_State* L)
{
    int HP = cast(int) luaL_checkinteger(L, 1);
    int mana = cast(int) luaL_checkinteger(L, 2);
    string name = to!string(cast(char*) luaL_checkstring(L, 3));
    int level = cast(int) luaL_checkinteger(L, 4);
    int XP = cast(int) luaL_checkinteger(L, 5);
    int counter = cast(int) luaL_checkinteger(L, 6);
    //partyMembers[0] = PartyMember(120, 120, 0, 0, "quantumde1", 1, 0);
    partyMembers[counter] = PartyMember(HP, HP, mana, mana, name, level, XP);
    return 0;
}

extern (C) nothrow int lua_setWalkAnimation(lua_State* L)
{
    modelAnimationWalk = cast(int) luaL_checkinteger(L, 1);
    return 0;
}

extern (C) nothrow int lua_setIdleAnimation(lua_State* L)
{
    modelAnimationIdle = cast(int) luaL_checkinteger(L, 1);
    return 0;
}

extern (C) nothrow int lua_setRunAnimation(lua_State* L)
{
    modelAnimationRun = cast(int) luaL_checkinteger(L, 1);
    return 0;
}

// Register drawing functions
extern (C) nothrow void luaL_opendrawinglib(lua_State* L)
{
    lua_register(L, "addCube", &lua_addCube);
    lua_register(L, "walkAnimationValue", &lua_setWalkAnimation);
    lua_register(L, "idleAnimationValue", &lua_setIdleAnimation);
    lua_register(L, "runAnimationValue", &lua_setRunAnimation);
    lua_register(L, "addPartyMember", &lua_addPartyMember);
    lua_register(L, "checkInventoryForObject", &lua_checkObjectInInventory);
    lua_register(L, "setCameraRotationSpeed", &lua_setCameraRotationSpeed);
    lua_register(L, "configureInventoryTabs", &lua_configureInventoryTabs);
    lua_register(L, "addToInventoryTab", &lua_addToInventoryTab);
    lua_register(L, "setPlayerCollisionSize", &lua_setPlayerCollisionSize);
    lua_register(L, "isCubeMoving", &lua_cubeMoveStatus);
    lua_register(L, "setCubeModel", &lua_setCubeModel);
    lua_register(L, "removeCubeModel", &lua_removeCubeModel);
    lua_register(L, "getPlayerX", &lua_getPlayerXPos);
    lua_register(L, "getPlayerY", &lua_getPlayerYPos);
    lua_register(L, "getPlayerZ", &lua_getPlayerZPos);
    lua_register(L, "setPlayerXYZ", &lua_setPlayerXYZPos);
    lua_register(L, "getCubeX", &lua_getCubeXPos);
    lua_register(L, "getCubeY", &lua_getCubeYPos);
    lua_register(L, "getCubeZ", &lua_getCubeZPos);
    lua_register(L, "getCameraX", &lua_getCameraXPos);
    lua_register(L, "getCameraY", &lua_getCameraYPos);
    lua_register(L, "getCameraZ", &lua_getCameraZPos);
    lua_register(L, "howMuchModels", &lua_howMuchModels);
    lua_register(L, "rotateCamera", &luaL_rotateCam);
    lua_register(L, "loadScript", &luaL_loadScript);
    lua_register(L, "allowDemons", &lua_allowDemons);
    lua_register(L, "setPlayerModel", &lua_setMcModel);
    lua_register(L, "removeCube", &lua_removeCube);
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

// Register functions in Lua
extern (C) nothrow void luaL_openaudiolib(lua_State* L)
{
    lua_register(L, "loadMusic", &lua_LoadMusic);
    lua_register(L, "playMusic", &lua_PlayMusic);
    lua_register(L, "stopMusic", &lua_StopMusic);
    lua_register(L, "setPlayerSize", &lua_setPlayerSize);
    lua_register(L, "loadMusicExternal", &lua_LoadMusicExternal);
    lua_register(L, "hideUI", &luaL_hideUI);
    lua_register(L, "openMap", &luaL_openMap);
}

// Initialization function to register all libraries
extern (C) nothrow void luaL_registerAllLibraries(lua_State* L)
{
    luaL_opendialoglib(L);
    luaL_openaudiolib(L);
    luaL_opendrawinglib(L);
    luaL_openmovelib(L);
}
