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
        isBossfight = true;
        name_global = to!string(luaL_checkstring(L, 3));
        message_global = [to!string(luaL_checkstring(L, 4))];
    } else {
        isBossfight = false;
    }
    playerStepCounter = 0;
    inBattle = true;
    try {
        initBattle(camera, cubePosition, cameraAngle, to!int(luaL_checkinteger(L, 1))-1);
    } catch (Exception e) {

    }
    return 0;
}

extern (C) nothrow lua_getBattleStatus(lua_State *L) {
    //status mean ended or not
    lua_pushboolean(L, inBattle);
    return 1;
}

extern (C) nothrow lua_setRotationCrowler(lua_State *L) {
    if (luaL_checkinteger(L, 1) == 1) {
        dungeonCrawlerMode = 1;
    } else if (luaL_checkinteger(L, 1) == 0) {
        dungeonCrawlerMode = 0;
    }
    return 0;
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

extern (C) nothrow int lua_setFriendlyZone(lua_State *L) {
    if (luaL_checkinteger(L, 1) == 0) {
        friendlyZone = false;
    }
    if (luaL_checkinteger(L, 1) == 1) {
        friendlyZone = true;
    }
    return 0;
}

extern (C) nothrow int lua_removeCube(lua_State *L) {
    try { if (!rel) {
    writeln("Removing: ", to!string(luaL_checkstring(L, 1))); }
    removeCube(to!string(luaL_checkstring(L, 1)));
    } catch (Exception e) {}
    return 0;
}

extern (C) nothrow int lua_playVideo(lua_State *L) {
    try {
        StopMusicStream(music);
        videoFinished = false;
        version (Windows) {
            playVideo(cast(char*)toStringz("/"~getcwd()~"/"~luaL_checkstring(L, 1).to!string));
        }
        version (Posix) {
            playVideo(cast(char*)toStringz(getcwd()~"/"~luaL_checkstring(L, 1).to!string));
        }
    } catch (Exception e) {}
    return 0;
}

extern (C) nothrow int lua_changeCameraPosition(lua_State *L) {
    newCameraNeeded = true;
    positionCam = Vector3(
        luaL_checknumber(L, 1),
        luaL_checknumber(L, 2),
        luaL_checknumber(L, 3)
    );
    return 0;
}

extern (C) nothrow int lua_changeCameraUp(lua_State *L) {
    newCameraNeeded = true;
    upCam = Vector3(
        luaL_checknumber(L, 1),
        luaL_checknumber(L, 2),
        luaL_checknumber(L, 3)
    );
    return 0;
}

extern (C) nothrow int lua_changeCameraTarget(lua_State *L) {
    newCameraNeeded = true;
    targetCam = Vector3(
        luaL_checknumber(L, 1),
        luaL_checknumber(L, 2),
        luaL_checknumber(L, 3)
    );
    return 0;
}

extern (C) nothrow int lua_drawPlayerModel(lua_State *L) {
    if (luaL_checkinteger(L, 1) == 0) {
        drawPlayer = false;
    }
    if (luaL_checkinteger(L, 1) == 1) {
        drawPlayer = true;
    }
    return 0;
}

extern (C) nothrow int lua_getDialogName(lua_State *L) {
    lua_pushstring(L, name_global.toStringz());
    return 1; // Number of return values
}

extern (C) nothrow int luaL_loadlocation(lua_State* L) {
    loadLocation(cast(char*)luaL_checkstring(L, 1), luaL_checknumber(L, 2));
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

string hint;

extern (C) nothrow int luaL_showHint(lua_State *L) {
    hint = "Hint: "~to!string(luaL_checkstring(L, 1));
    hintNeeded = true;
    return 0;
}

extern (C) nothrow int luaL_hideHint(lua_State *L) {
    hintNeeded = false;
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

extern (C) nothrow int luaL_hideUI(lua_State *L) {
    hideNavigation = true;
    return 0;
}

extern (C) nothrow int luaL_openMap(lua_State *L){
    StopMusicStream(music);
    import graphics.map;
    try { openMap(to!string(luaL_checkstring(L, 1)), to!string(luaL_checkstring(L, 2))); } catch (Exception e) {}
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
    emotion_global = cast(char*)luaL_checkstring(L, 3);
    try {
        uint image_size;
        char *image_data = get_file_data_from_archive("res/faces.bin", emotion_global, &image_size);
        dialogImage = LoadTextureFromImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size));
        UnloadImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size));
    } catch (Exception e) {}
    // Get the choices array from the Lua stack
    luaL_checktype(L, 5, LUA_TTABLE);
    int choicesLength = cast(int)lua_objlen(L, 5);
    choices = new string[choicesLength];
    for (int i = 0; i < choicesLength; i++) {
        lua_rawgeti(L, 5, i + 1); // Lua indices start from 1
        choices[i] = luaL_checkstring(L, -1).to!string;
        lua_pop(L, 1);
    }
    int x_pos = cast(int)luaL_checkinteger(L, 6);
    if (x_pos == 0) {
        pos = false;
    }
    if (x_pos == 1) {
        pos = true;
    }
    if (lua_gettop(L) == 7) {
        typingSpeed = cast(float)luaL_checknumber(L, 7);
    } else {
        typingSpeed = 0.03f;
    }
    showDialog = true;
    allowControl = false;
    show_sec_dialog = true;
    
    return 0;
}

extern (C) nothrow int lua_draw2Dbackground(lua_State *L) {
    uint image_size;
    try {
    char *image_data = get_file_data_from_archive("res/bg.bin", luaL_checkstring(L, 1), &image_size);
    texture_background = LoadTextureFromImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size));
    UnloadImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size));
    neededDraw2D = true;
    } catch (Exception e) {

    }
    return 0;
}

extern (C) nothrow int lua_draw2Dobject(lua_State *L) {
    uint image_size;
    neededCharacterDrawing = true;
    int count = cast(int)luaL_checkinteger(L, 5);
    try {
    char *image_data = get_file_data_from_archive("res/tex.bin", luaL_checkstring(L, 1), &image_size);
    tex2d[count].texture = LoadTextureFromImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size));
    UnloadImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size));
    tex2d[count].x = cast(int)luaL_checkinteger(L, 2);
    tex2d[count].y = cast(int)luaL_checkinteger(L, 3);
    tex2d[count].scale = luaL_checknumber(L, 4);
    } catch (Exception e) {
        
    }
    return 0;
}

extern (C) nothrow int lua_stopDraw2Dobject(lua_State *L) {
    int count = cast(int)luaL_checkinteger(L, 1);
    UnloadTexture(tex2d[count].texture);
    neededCharacterDrawing = false;
    return 0;
}

extern (C) nothrow int lua_showNameInput(lua_State *L) {
    try {
        showCharacterNameInputMenu = true;
    } catch (Exception e) {

    }
    return 0;
}

extern (C) nothrow int lua_getScreenWidth(lua_State *L) {
    lua_pushinteger(L, GetScreenWidth());
    return 1;
}

extern (C) nothrow int lua_getScreenHeight(lua_State *L) {
    lua_pushinteger(L, GetScreenHeight());
    return 1;
}

extern (C) nothrow int lua_stop2Dbackground(lua_State *L) {
    UnloadTexture(texture_background);
    neededDraw2D = false;
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
    lua_register(L, "inputName", &lua_showNameInput);
    lua_register(L, "getBattleStatus", &lua_getBattleStatus);
    lua_register(L, "getDialogName", &lua_getDialogName);
    lua_register(L, "showHint", &luaL_showHint);
    lua_register(L, "hideHint", &luaL_hideHint);
    lua_register(L, "dungeonCrawlerMode", &lua_setRotationCrowler);
    lua_register(L, "updateCubeDialog", &lua_updateCubeDialog);
    lua_register(L, "draw2Dtexture", &lua_draw2Dbackground);
    lua_register(L, "draw2Dcharacter", &lua_draw2Dobject);
    lua_register(L, "getScreenHeight", &lua_getScreenHeight);
    lua_register(L, "getScreenWidth", &lua_getScreenWidth);
    lua_register(L, "stopDraw2Dtexture", &lua_stop2Dbackground);
    lua_register(L, "playVideo", &lua_playVideo);
    lua_register(L, "drawPlayerModel", &lua_drawPlayerModel);
    lua_register(L, "getAnswerValue", &lua_getAnswerValue);
    lua_register(L, "clearChoice", &luaL_dialogClearChoice);
}

// Music functions
extern (C) nothrow int lua_LoadMusic(lua_State *L) {
    meow:
    try {
        musicpath = cast(char*)luaL_checkstring(L, 1);
        uint audio_size;
        char *audio_data = get_file_data_from_archive("res/data.bin", musicpath, &audio_size);
        
        if (audioEnabled) {
            UnloadMusicStream(music);
            music = LoadMusicStreamFromMemory(".mp3", cast(const(ubyte)*)audio_data, audio_size);
        }
    } catch (Exception e) {
    }
    return 0;
}

extern (C) nothrow int lua_LoadMusicExternal(lua_State *L) {
    meow:
    try {
        musicpath = cast(char*)luaL_checkstring(L, 1);
        music = LoadMusicStream(musicpath);
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
    lua_register(L, "stopDraw2Dcharacter", &lua_stopDraw2Dobject);
    lua_register(L, "setFriendlyZone", &lua_setFriendlyZone);
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

extern (C) nothrow int lua_getPlayerXPos(lua_State *L) {
    lua_pushnumber(L, cast(int)cubePosition.x);
    return 1;
}

extern (C) nothrow int lua_getPlayerYPos(lua_State *L) {
    lua_pushnumber(L, cast(int)cubePosition.y);
    return 1;
}

extern (C) nothrow int lua_getPlayerZPos(lua_State *L) {
    lua_pushnumber(L, cast(int)cubePosition.z);
    return 1;
}

extern (C) nothrow int lua_setPlayerXYZPos(lua_State *L) {
    cubePosition = Vector3(luaL_checknumber(L,1), luaL_checknumber(L,2), luaL_checknumber(L, 3));
    return 1;
}

extern (C) nothrow int lua_getCubeXPos(lua_State *L) {
    lua_pushnumber(L, cubes[luaL_checkinteger(L, 1)-1].boundingBox.min.x);
    return 1;
}

extern (C) nothrow int lua_getCubeYPos(lua_State *L) {
    lua_pushnumber(L, cubes[luaL_checkinteger(L, 1)-1].boundingBox.min.y);
    return 1;
}

extern (C) nothrow int lua_getCubeZPos(lua_State *L) {
    lua_pushnumber(L, cubes[luaL_checkinteger(L, 1)-1].boundingBox.min.z);
    return 1;
}

extern (C) nothrow int lua_getCameraXPos(lua_State *L) {
    lua_pushnumber(L, positionCam.x);
    return 1;
}

extern (C) nothrow int lua_getCameraYPos(lua_State *L) {
    lua_pushnumber(L, positionCam.y);
    return 1;
}

extern (C) nothrow int lua_getCameraZPos(lua_State *L) {
    lua_pushnumber(L, positionCam.z);
    return 1;
}

// Cube management functions
extern (C) nothrow int lua_addCube(lua_State *L) {
    auto name = luaL_checkstring(L, 4);
    char* emotion = cast(char*)luaL_checkstring(L, 6);
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
    modelCharacterSize = luaL_checknumber(L, 2);
    return 0;
}

extern (C) nothrow int lua_setCubeModel(lua_State *L) {
    int index = cast(int)luaL_checkinteger(L, 1) - 1;
    const char* modelPath = luaL_checkstring(L, 2);
    modelCubeSize = luaL_checknumber(L, 3);
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

extern (C) nothrow int luaL_openInputNameMenu(lua_State *L) {
    showCharacterNameInputMenu = true;
    return 0;
}

// Register functions in Lua
extern (C) nothrow void luaL_openaudiolib(lua_State* L) {
    lua_register(L, "loadMusic", &lua_LoadMusic);
    lua_register(L, "showNameInput", &luaL_openInputNameMenu);
    lua_register(L, "playMusic", &lua_PlayMusic);
    lua_register(L, "stopMusic", &lua_StopMusic);
    lua_register(L, "loadMusicExternal", &lua_LoadMusicExternal);
    lua_register(L, "hideUI", &luaL_hideUI);
    lua_register(L, "openMap", &luaL_openMap);
}

// Initialization function to register all libraries
extern (C) nothrow void luaL_registerAllLibraries(lua_State* L) {
    luaL_opendialoglib(L);
    luaL_openaudiolib(L);
    luaL_opendrawinglib(L);
    luaL_openmovelib(L);
}