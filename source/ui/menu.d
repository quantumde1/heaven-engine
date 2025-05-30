module ui.menu;

import raylib;
import variables;
import std.stdio;
import scripts.config;
import core.time;
import core.thread;
import std.string;
import graphics.engine;
import graphics.video;
import std.file;
import ui.common;

enum
{
    MENU_ITEM_START = 0,
    MENU_ITEM_LANGUAGE = 1,
    MENU_ITEM_SHADERS = 2,
    MENU_ITEM_SOUND = 3,
    MENU_ITEM_SFX = 4,
    MENU_ITEM_FULLSCREEN = 5,
    MENU_ITEM_FPS = 6,
    MENU_ITEM_EXIT = 7,

    FADE_SPEED_IN = 0.02f,
    FADE_SPEED_OUT = 0.04f,
    INACTIVITY_TIMEOUT = 20.0f
}

struct MenuState
{
    string[] options;
    int selectedIndex;
    float fadeAlpha;
    float inactivityTimer;
    Texture2D logoTexture;
    Music menuMusic;
    bool fromSave;
    int logoX, logoY;
}

void renderText(float alpha, immutable(char)* text)
{
    DrawTextEx(fontdialog, text,
        Vector2(GetScreenWidth() / 2 - MeasureText(text, 40) / 2,
            GetScreenHeight() / 2), 40, 0, Fade(Colors.WHITE, alpha)
    );
}

void renderLogo(float alpha, immutable(char)* name, bool fullscreen)
{
    uint image_size;
    char* image_data_logo = get_file_data_from_archive("res/data.bin", name, &image_size);
    Texture2D atlus = LoadTextureFromImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*) image_data_logo, image_size));
    UnloadImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*) image_data_logo, image_size));

    if (fullscreen)
    {
        DrawTexturePro(atlus,
            Rectangle(0, 0, cast(float) atlus.width, cast(float) atlus.height),
            Rectangle(0, 0, cast(float) GetScreenWidth(), cast(float) GetScreenHeight()),
            Vector2(0, 0), 0.0, Fade(Colors.WHITE, alpha));
    }
    else
    {
        DrawTexture(atlus, GetScreenWidth() / 2, GetScreenHeight() / 2, Colors.WHITE);
    }
}

void helloScreen()
{
    fadeEffect(0.0f, true, (float alpha) {
        renderText(alpha, "powered by\n\nHeaven Engine");
    });

    fadeEffect(2.0f, false, (float alpha) {
        renderText(alpha, "powered by\n\nHeaven Engine");
    });
    /*
    fadeEffect(0.0f, true, (float alpha) {
        renderLogo(alpha, "atlus_logo.png".toStringz, true);
    });
    
    fadeEffect(fadeAlpha, false, (float alpha) {
        renderLogo(alpha, "atlus_logo.png".toStringz, true);
    });
    */
    // Play Opening Video
    BeginDrawing();
    debug debug_writeln("searching for video");
    if (std.file.exists(getcwd() ~ "/res/videos/soul_OP.moflex.mp4"))
    {
        debug debug_writeln("video found, playing");
        version (Windows)
        {
            playVideo(cast(char*)("/" ~ getcwd() ~ "/res/videos/soul_OP.moflex.mp4"));
        }
        version (Posix)
        {
            playVideo(cast(char*)(getcwd() ~ "/res/videos/soul_OP.moflex.mp4"));
        }
    }
    else
    {
        debug debug_writeln("video not found, skipping");
        videoFinished = true;
    }
}

MenuState initMenuState()
{
    MenuState state;
    state.fromSave = std.file.exists(getcwd() ~ "/save.txt");
    state.options = [
        "Start Game", 
        "Language: English", 
        "Shaders: On", 
        "Sound: On",
        "SFX: On",
        "Fullscreen: On",
        "FPS: 60",
        "Exit Game",
    ];

    if (state.fromSave)
        state.options[MENU_ITEM_START] = "Continue";
    if (!audioEnabled)
        state.options[MENU_ITEM_SOUND] = "Sound: Off";

    state.fadeAlpha = 0.0f;
    state.inactivityTimer = 0.0f;
    state.selectedIndex = 0;

    uint imageSize;
    char* imageData = get_file_data_from_archive("res/data.bin", "logo.png", &imageSize);
    state.logoTexture = LoadTextureFromImage(
        LoadImageFromMemory(".PNG", cast(const(ubyte)*) imageData, imageSize)
    );
    UnloadImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*) imageData, imageSize));

    state.logoX = (GetScreenWidth() - state.logoTexture.width) / 2;
    state.logoY = (GetScreenHeight() - state.logoTexture.height) / 2 - 50;

    uint audioSize;
    char* audioData = get_file_data_from_archive("res/data.bin", "main_menu.mp3", &audioSize);
    state.menuMusic = LoadMusicStreamFromMemory(".mp3", cast(const(ubyte)*) audioData, audioSize);
    if (audioEnabled)
    {
        PlayMusicStream(state.menuMusic);
    }
    audio.declineSound = LoadSound("res/sfx/10002.wav");
    audio.acceptSound = LoadSound("res/sfx/10003.wav");
    audio.menuMoveSound = LoadSound("res/sfx/10004.wav");
    audio.menuChangeSound = LoadSound("res/sfx/00152.wav");
    audio.nonSound = LoadSound("res/sfx/00154.wav");
    return state;
}

void cleanupMenu(ref MenuState state)
{
    UnloadTexture(state.logoTexture);
    UnloadMusicStream(state.menuMusic);
}

void drawMenu(ref const MenuState state)
{
    BeginDrawing();
    ClearBackground(Colors.BLACK);

    DrawTextureEx(
        state.logoTexture,
        Vector2(state.logoX, state.logoY),
        0.0f, 1.0f,
        Fade(Colors.WHITE, state.fadeAlpha)
    );

    for (int i = 0; i < state.options.length; i++)
    {
        Color textColor = (i == state.selectedIndex) ? Colors.LIGHTGRAY : Colors.GRAY;
        float textWidth = MeasureTextEx(fontdialog, toStringz(state.options[i]), 30, 0).x;
        float textX = (GetScreenWidth() - textWidth) / 2;
        int textY = state.logoY + state.logoTexture.height + 100 + (30 * i);

        DrawTextEx(
            fontdialog,
            toStringz(state.options[i]),
            Vector2(textX, textY),
            30, 0,
            Fade(textColor, state.fadeAlpha)
        );
    }

    EndDrawing();
}

void handleInactivity(ref MenuState state)
{
    state.inactivityTimer += GetFrameTime();

    if (state.inactivityTimer >= INACTIVITY_TIMEOUT)
    {
        while (state.fadeAlpha > 0.0f)
        {
            state.fadeAlpha -= FADE_SPEED_OUT;
            if (state.fadeAlpha < 0.0f)
                state.fadeAlpha = 0.0f;
            drawMenu(state);
        }

        StopMusicStream(state.menuMusic);
        version (Posix)
            playVideo(cast(char*)(getcwd() ~ "/res/videos/opening_old.mp4"));
        version (Windows)
            playVideo(cast(char*)("/" ~ getcwd() ~ "/res/videos/opening_old.mp4"));

        if (audioEnabled)
        {
            PlayMusicStream(state.menuMusic);
        }

        state.inactivityTimer = 0.0f;

        while (state.fadeAlpha < 1.0f)
        {
            state.fadeAlpha += FADE_SPEED_IN;
            if (state.fadeAlpha > 1.0f)
                state.fadeAlpha = 1.0f;
            drawMenu(state);
        }
    }
}

void handleMenuNavigation(ref MenuState state)
{
    bool moved = false;

    if (IsKeyPressed(KeyboardKey.KEY_DOWN) ||
        IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN))
    {
        state.selectedIndex = cast(int)((state.selectedIndex + 1) % state.options.length);
        state.inactivityTimer = 0;
        moved = true;
    }

    if (IsKeyPressed(KeyboardKey.KEY_UP) ||
        IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP))
    {
        state.selectedIndex = cast(int)(
            (state.selectedIndex - 1 + state.options.length) % state.options.length);
        state.inactivityTimer = 0;
        moved = true;
    }

    if (moved && sfxEnabled)
    {
        PlaySound(audio.menuMoveSound);
    }
}

void handleMenuSettings(ref MenuState state)
{
    bool leftPressed = IsKeyPressed(KeyboardKey.KEY_LEFT) ||
        IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT);
    bool rightPressed = IsKeyPressed(KeyboardKey.KEY_RIGHT) ||
        IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT);

    if (!leftPressed && !rightPressed)
        return;

    state.inactivityTimer = 0;

    if (sfxEnabled) PlaySound(audio.menuChangeSound);

    switch (state.selectedIndex)
    {
    case MENU_ITEM_LANGUAGE:
        if (rightPressed)
        {
            usedLang = "russian";
            state.options[MENU_ITEM_LANGUAGE] = "Language: Russian";
        }
        else if (leftPressed)
        {
            usedLang = "english";
            state.options[MENU_ITEM_LANGUAGE] = "Language: English";
        }
        break;

    case MENU_ITEM_SHADERS:
        shaderEnabled = rightPressed ? false : true;
        state.options[MENU_ITEM_SHADERS] = shaderEnabled ? "Shaders: On" : "Shaders: Off";
        break;

    case MENU_ITEM_SOUND:
        audioEnabled = rightPressed ? false : true;
        state.options[MENU_ITEM_SOUND] = audioEnabled ? "Sound: On" : "Sound: Off";

        if (audioEnabled)
        {
            PlayMusicStream(state.menuMusic);
        }
        else
        {
            StopMusicStream(state.menuMusic);
        }
        break;
    case MENU_ITEM_SFX:
        sfxEnabled = rightPressed ? false : true;
        state.options[MENU_ITEM_SFX] = sfxEnabled ? "SFX: On" : "SFX: Off";
        break;

    case MENU_ITEM_FULLSCREEN:
        fullscreenEnabled = rightPressed ? false : true;
        state.options[MENU_ITEM_FULLSCREEN] = fullscreenEnabled ? "Fullscreen: On" : "Fullscreen: Off";
        if (fullscreenEnabled) {
            if (!IsWindowFullscreen()) {
                ToggleFullscreen();
                HideCursor();
                
            }
        } else if (fullscreenEnabled == false) {
            if (IsWindowFullscreen()) {
                ToggleFullscreen();
                ShowCursor();
            }
        }
        break;

    case MENU_ITEM_FPS:
        FPS = rightPressed ? 30 : 60;
        SetTargetFPS(FPS);
        state.options[MENU_ITEM_FPS] = format("FPS: %d", FPS);
        break;

    default:
        break;
    }
}

void showMainMenu(ref GameState currentGameState)
{
    MenuState state = initMenuState();

    while (state.fadeAlpha < 1.0f)
    {
        state.fadeAlpha += FADE_SPEED_IN;
        if (state.fadeAlpha > 1.0f)
            state.fadeAlpha = 1.0f;
        drawMenu(state);
    }

    while (!WindowShouldClose())
    {
        UpdateMusicStream(state.menuMusic);

        if (IsKeyPressed(KeyboardKey.KEY_F3))
        {
            showDebug = true;
        }

        if (showDebug)
        {
            debug drawDebugInfo(cubePosition, currentGameState,
                partyMembers[0].currentHealth,
                cameraAngle, playerStepCounter,
                encounterThreshold, inBattle);
        }

        handleInactivity(state);
        handleMenuNavigation(state);
        handleMenuSettings(state);

        if (IsKeyPressed(KeyboardKey.KEY_ENTER) ||
            IsKeyPressed(KeyboardKey.KEY_SPACE) ||
            IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN))
        {
            if (sfxEnabled) PlaySound(audio.acceptSound);
            switch (state.selectedIndex)
            {
            case MENU_ITEM_START:
                while (state.fadeAlpha > 0.0f)
                {
                    state.fadeAlpha -= FADE_SPEED_OUT;
                    if (state.fadeAlpha < 0.0f)
                        state.fadeAlpha = 0.0f;
                    drawMenu(state);
                }

                cleanupMenu(state);
                currentGameState = GameState.InGame;
                debug_writeln("getting into game...");
                return;

            case MENU_ITEM_EXIT:
                cleanupMenu(state);
                currentGameState = GameState.Exit;
                return;

            default:
                break;
            }
        }

        drawMenu(state);
    }

    cleanupMenu(state);
}