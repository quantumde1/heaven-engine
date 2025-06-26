module system.cleanup;

import std.stdio;
import variables;
import raylib;
import system.abstraction;

void unloadResourcesLogic()
{
    debugWriteln("Exiting. See ya'!");
    StopMusicStream(music);
    EndDrawing();
    if (sfxEnabled) {
        UnloadSound(audio.menuMoveSound);
        UnloadSound(audio.acceptSound);
        UnloadSound(audio.menuChangeSound);
        UnloadSound(audio.declineSound);
        UnloadSound(audio.nonSound);
    }
    UnloadFont(textFont);
    for (int i = cast(int) characterTextures.length; i < characterTextures.length; i++)
    {
        UnloadTexture(characterTextures[i].texture);
    }
    for (int i = cast(int) backgrounds.length; i < backgrounds.length; i++)
    {
        UnloadTexture(backgrounds[i]);
    }
    UnloadMusicStream(music);
    CloseAudioDevice();
    CloseWindow();
}