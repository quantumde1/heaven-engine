module graphics.gamelogic;

import raylib;
import bindbc.lua;
import variables;
import core.stdc.stdlib;
import core.stdc.time;
import graphics.engine;
import scripts.lua;
import std.stdio;
import std.conv;
import graphics.effects;
import std.string;
import std.math;
import dialogs.dialogbox;
import system.abstraction;
import system.config;
import std.file;

/** 
 * this module contains game logic, which was removed from engine.d for better readability.
 */
 
void gameInit()
{
    if (WindowShouldClose()) {
        currentGameState = GameState.Exit;
    } else {
        debugWriteln("Game initializing.");
        systemSettings = loadSettingsFromConfigFile();
        if (sfxEnabled == false) {
            UnloadSound(audio.menuMoveSound);
            UnloadSound(audio.acceptSound);
            UnloadSound(audio.menuChangeSound);
            UnloadSound(audio.declineSound);
            UnloadSound(audio.nonSound);
        }
    }
}

void effectsLogic()
{
    UpdateMusicStream(music);
    if (isCameraMoving) {
        float delta = GetFrameTime() * cameraMoveSpeed;
        camera.target.x += (cameraTargetX - camera.target.x) * delta;
        camera.target.y += (cameraTargetY - camera.target.y) * delta;
        camera.zoom += (cameraTargetZoom - camera.zoom) * delta;

        if (fabs(camera.target.x - cameraTargetX) < 5.0f &&
            fabs(camera.target.y - cameraTargetY) < 5.0f &&
            fabs(camera.zoom - cameraTargetZoom) < 0.5f) {
            isCameraMoving = false;
        }
    }
    playUIAnimation(framesUI);
}

void backgroundLogic() {
    if (neededDraw2D)
    {
        DrawTexturePro(backgroundTexture, Rectangle(0, 0, cast(float) backgroundTexture.width, cast(
                float) backgroundTexture.height), Rectangle(0, 0, cast(float) GetScreenWidth(), cast(
                float) GetScreenHeight()), Vector2(0, 0), 0.0, Colors.WHITE);
    }
    for (int i = 0; i < characterTextures.length; i++)
    {
        if (characterTextures[i].drawTexture == true) {
            float centeredX = characterTextures[i].x - (characterTextures[i].width * characterTextures[i].scale / 2);
            float centeredY = characterTextures[i].y - (characterTextures[i].height * characterTextures[i].scale / 2);
            
            DrawTextureEx(characterTextures[i].texture,
                        Vector2(centeredX, centeredY), 
                        0.0, 
                        characterTextures[i].scale, 
                        Colors.WHITE);
        }
    }
}

void dialogLogic() {
    if (showDialog) {
        displayDialog(messageGlobal, choices, selectedChoice, choicePage, textFont, &showDialog, typingSpeed);
    }
}