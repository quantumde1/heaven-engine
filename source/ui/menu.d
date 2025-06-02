module ui.menu;

import raylib;
import variables;
import std.stdio;
import scripts.config;
import core.time;
import core.thread;
import std.string;
import graphics.engine;
import graphics.playback;
import std.file;

enum
{
    MENU_ITEM_START = 0,
    MENU_ITEM_SOUND = 1,
    MENU_ITEM_SFX = 2,
    MENU_ITEM_FULLSCREEN = 3,
    MENU_ITEM_EXIT = 4,

    FADE_SPEED_IN = 0.02f,
    FADE_SPEED_OUT = 0.04f,
    INACTIVITY_TIMEOUT = 20.0f
}

void fadeEffect(float alpha, bool fadeIn, void delegate(float alpha) renderer)
{
    const float FadeIncrement = 0.02f;

    while (fadeIn ? alpha < 2.0f : alpha > 0.0f)
    {
        alpha += fadeIn ? FadeIncrement : -FadeIncrement;
        BeginDrawing();
        ClearBackground(Colors.BLACK);
        renderer(alpha);
        EndDrawing();
    }
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
    DrawTextEx(textFont, text,
        Vector2(GetScreenWidth() / 2 - MeasureText(text, 40) / 2,
            GetScreenHeight() / 2), 40, 0, Fade(Colors.WHITE, alpha)
    );
}

void renderLogo(float alpha, immutable(char)* name, bool fullscreen)
{
    Texture2D companyLogo = LoadTexture(name);
    if (fullscreen)
    {
        DrawTexturePro(companyLogo,
            Rectangle(0, 0, cast(float) companyLogo.width, cast(float) companyLogo.height),
            Rectangle(0, 0, cast(float) GetScreenWidth(), cast(float) GetScreenHeight()),
            Vector2(0, 0), 0.0, Fade(Colors.WHITE, alpha));
    }
    else
    {
        DrawTexture(companyLogo, GetScreenWidth() / 2, GetScreenHeight() / 2, Colors.WHITE);
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
        playVideo("/res/videos/soul_OP.moflex.mp4");
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
        "Sound: On",
        "SFX: On",
        "Fullscreen: On",
        "Exit Game",
    ];

    if (state.fromSave)
        state.options[MENU_ITEM_START] = "Continue";
    if (!audioEnabled)
        state.options[MENU_ITEM_SOUND] = "Sound: Off";

    state.fadeAlpha = 0.0f;
    state.inactivityTimer = 0.0f;
    state.selectedIndex = 0;

    state.logoTexture = LoadTexture("res/data/menu_logo.png");
    state.logoX = (GetScreenWidth() - state.logoTexture.width) / 2;
    state.logoY = (GetScreenHeight() - state.logoTexture.height) / 2 - 50;

    state.menuMusic = LoadMusicStream("res/data/menu_music.mp3");
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
        float textWidth = MeasureTextEx(textFont, toStringz(state.options[i]), 30, 0).x;
        float textX = (GetScreenWidth() - textWidth) / 2;
        int textY = state.logoY + state.logoTexture.height + 100 + (30 * i);

        DrawTextEx(
            textFont,
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
        playVideo("/res/videos/opening_old.mp4");
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

    if (IsKeyPressed(KeyboardKey.KEY_DOWN))
    {
        state.selectedIndex = cast(int)((state.selectedIndex + 1) % state.options.length);
        state.inactivityTimer = 0;
        moved = true;
    }

    if (IsKeyPressed(KeyboardKey.KEY_UP))
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
    bool leftPressed = IsKeyPressed(KeyboardKey.KEY_LEFT);
    bool rightPressed = IsKeyPressed(KeyboardKey.KEY_RIGHT);

    if (!leftPressed && !rightPressed)
        return;

    state.inactivityTimer = 0;

    if (sfxEnabled) PlaySound(audio.menuChangeSound);

    switch (state.selectedIndex)
    {
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


        handleInactivity(state);
        handleMenuNavigation(state);
        handleMenuSettings(state);

        if (IsKeyPressed(KeyboardKey.KEY_ENTER) ||
            IsKeyPressed(KeyboardKey.KEY_SPACE))
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
                debug debug_writeln("getting into game...");
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