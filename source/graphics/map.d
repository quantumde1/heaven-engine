// quantumde1 developed software, licensed under BSD-0-Clause license.
module graphics.map;

import raylib;
import graphics.scene;
import std.stdio;
import std.string;
import graphics.engine;
import scripts.config;
import variables;
import std.conv;
import std.algorithm;
import std.uni: isWhite;

bool mapOpened;
string locationname;

struct LocationData {
    string[] menuOptions;
    string[] locationNames;
    int[] rectX;
    int[] rectY;
}

LocationData akenadaiData = {
    ["Home", "Astro Museum", "Akane Mall"],
    ["home", "planetarium", "akanemall"],
    [0, 0, 0], // Пример координат
    [0, 0, 0]  // Пример координат
};

LocationData shibahamaData = {
    ["Shibahama Core", "Goumaden", "South Parking"],
    ["core", "goumaden", "garage"],
    [373, 773, 806], // Пример координат
    [790, 390, 810]  // Пример координат
};

void openMap(string location, bool fromScript) {
    mapOpened = true;
    const int screenWidth = GetScreenWidth();
    const int screenHeight = GetScreenHeight();
    int selectedMenuIndex = 0;
    float timeElapsed = 0.0f;
    float animationSpeed = 0.07f;

    // Load textures and music
    Texture2D mapTextureAkenadai = loadTextureFromArchive("res/data.bin", "akenadai_map.png");
    Texture2D mapTextureShibahama = loadTextureFromArchive("res/data.bin", "shibahama_map.png");
    Music musicMenu = loadMusicFromArchive("res/data.bin", "map_music.mp3");

    if (audioEnabled) {
        PlayMusicStream(musicMenu);
    }

    Texture2D[] arrowTextures = loadArrowTextures();

    int currentFrame = 0;
    string currentArea = "Akenadai"; // Default area
    LocationData currentLocationData = akenadaiData;

    fadeInEffect(screenWidth, screenHeight, mapTextureAkenadai, mapTextureShibahama, currentArea);

    while (!WindowShouldClose()) {
        UpdateMusicStream(musicMenu);
        timeElapsed += GetFrameTime();
        if (timeElapsed >= animationSpeed) {
            currentFrame = cast(int)((currentFrame + 1) % arrowTextures.length);
            timeElapsed = 0.0f;
        }

        drawUI(screenWidth, screenHeight, currentArea, currentLocationData, selectedMenuIndex, mapTextureAkenadai, mapTextureShibahama, arrowTextures[currentFrame]);

        if (IsKeyPressed(KeyboardKey.KEY_TAB) || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_TRIGGER_1) || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_TRIGGER_2)) {
            currentArea = (currentArea == "Akenadai") ? "Shibahama" : "Akenadai";
            currentLocationData = (currentArea == "Akenadai") ? akenadaiData : shibahamaData;
            selectedMenuIndex = 0; // Reset selection when switching areas
        }

        if (IsKeyPressed(KeyboardKey.KEY_DOWN) || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN)) {
            selectedMenuIndex = cast(int)((selectedMenuIndex + 1) % currentLocationData.menuOptions.length);
        }
        if (IsKeyPressed(KeyboardKey.KEY_UP) || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP)) {
            selectedMenuIndex = cast(int)((selectedMenuIndex - 1 + currentLocationData.menuOptions.length) % currentLocationData.menuOptions.length);
        }

        if (handleSelection(currentArea, currentLocationData, selectedMenuIndex, fromScript, screenWidth, screenHeight, mapTextureAkenadai, mapTextureShibahama)) {
            break;
        }
    }

    unloadResources(mapTextureAkenadai, mapTextureShibahama, musicMenu, arrowTextures);
    mapOpened = false;
}

void drawUI(int screenWidth, int screenHeight, string currentArea, LocationData currentLocationData, int selectedMenuIndex, Texture2D mapTextureAkenadai, Texture2D mapTextureShibahama, Texture2D arrowTexture) {
    BeginDrawing();
    ClearBackground(Colors.RAYWHITE);
    drawMapTexture(screenWidth, screenHeight, mapTextureAkenadai, mapTextureShibahama, currentArea);

    DrawRectangle(0, 0, screenWidth / 2, 50, Color(100, 54, 65, 255));
    DrawTextEx(fontdialog, toStringz(currentArea), Vector2(20, 10), 30, 0, Colors.WHITE);

    DrawRectangle(screenWidth / 2, 0, screenWidth / 2, 50, Color(80, 54, 65, 255));
    DrawTextEx(fontdialog, toStringz((currentArea == "Akenadai") ? "Shibahama" : "Akenadai"), Vector2(screenWidth / 2 + 20, 10), 30, 0, Colors.GRAY);

    for (int i = 0; i < currentLocationData.menuOptions.length; i++) {
        Color buttonColor = (i == selectedMenuIndex) ? Color(0, 0, 0, 210) : Color(0, 0, 0, 150);
        DrawRectangleRounded(Rectangle(10, 60 + (30 * i), 200, 30), 0.03f, 16, buttonColor);
        DrawTextEx(fontdialog, toStringz(currentLocationData.menuOptions[i]), Vector2(20, 64 + (30 * i)), 20, 1.0f, Colors.WHITE);
    }
    DrawRectangleRoundedLinesEx(Rectangle(10, 60, 200, 30 * currentLocationData.menuOptions.length), 0.03f, 16, 3.0f, Color(100, 54, 65, 255)); // Outline

    float scaleFactor = 0.7f;
    DrawTexturePro(
        arrowTexture,
        Rectangle(0, 0, cast(float)arrowTexture.width, cast(float)arrowTexture.height),
        Rectangle(currentLocationData.rectX[selectedMenuIndex], currentLocationData.rectY[selectedMenuIndex], 100 * scaleFactor, 100 * scaleFactor),
        Vector2(0, 0),
        0.0,
        Colors.WHITE
    );

    int posY = GetScreenHeight() - 20 - 40;
    if (IsGamepadAvailable(gamepadInt)) {
        DrawText(toStringz("Press L1/R1/RB/LB for switching area"), 40, posY, 20, Colors.BLACK);
    } else {
        DrawText(toStringz("Press TAB for switching area"), 40, posY, 20, Colors.BLACK);
    }

    EndDrawing();
}

bool handleSelection(string currentArea, LocationData currentLocationData, int selectedMenuIndex, bool fromScript, int screenWidth, int screenHeight, Texture2D mapTextureAkenadai, Texture2D mapTextureShibahama) {
    if (IsKeyPressed(KeyboardKey.KEY_ENTER) || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) {
        locationname = currentLocationData.locationNames[selectedMenuIndex];
        float fadeOutAlpha = 0.0f;
        while (fadeOutAlpha < 255) {
            fadeOutAlpha += 5;
            if (fadeOutAlpha > 255) fadeOutAlpha = 255;

            BeginDrawing();
            ClearBackground(Colors.RAYWHITE);
            drawMapTexture(screenWidth, screenHeight, mapTextureAkenadai, mapTextureShibahama, currentArea);
            DrawRectangle(0, 0, screenWidth, 50, Color(100, 54, 65, 255));
            DrawTextEx(fontdialog, "Select destination", Vector2(20, 10), 30, 0, Colors.WHITE);

            for (int i = 0; i < currentLocationData.menuOptions.length; i++) {
                Color buttonColor = (i == selectedMenuIndex) ? Color(0, 0, 0, 210) : Color(0, 0, 0, 150);
                DrawRectangleRounded(Rectangle(10, 60 + (30 * i), 200, 30), 0.03f, 16, buttonColor);
                DrawTextEx(fontdialog, toStringz(currentLocationData.menuOptions[i]), Vector2(20, 64 + (30 * i)), 20, 1.0f, Colors.WHITE);
            }
            DrawRectangleRoundedLinesEx(Rectangle(10, 60, 200, 30 * currentLocationData.menuOptions.length), 0.03f, 16, 3.0f, Color(100, 54, 65, 255)); // Outline
            DrawRectangle(0, 0, screenWidth, screenHeight, Color(0, 0, 0, cast(ubyte)fadeOutAlpha)); // Draw fade rectangle
            EndDrawing();
        }

        if (fromScript) {
            debug {
                debug debug_writeln("Map called from script, not loading model");
            }
        }
        return true; // Exit the loop after loading the location
    }
    return false;
}

void unloadResources(Texture2D mapTextureAkenadai, Texture2D mapTextureShibahama, Music musicMenu, Texture2D[] arrowTextures) {
    UnloadTexture(mapTextureAkenadai);
    UnloadTexture(mapTextureShibahama);
    if (audioEnabled) {
        UnloadMusicStream(musicMenu);
        PlayMusicStream(music);
    }
    foreach (texture; arrowTextures) {
        UnloadTexture(texture);
    }
}

Texture2D loadTextureFromArchive(string archivePath, string fileName) {
    uint image_size;
    char *image_data = get_file_data_from_archive(toStringz(archivePath), toStringz(fileName), &image_size);
    Texture2D texture = LoadTextureFromImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size));
    UnloadImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size));
    return texture;
}

Music loadMusicFromArchive(string archivePath, string fileName) {
    uint audio_size;
    char *audio_data = get_file_data_from_archive(toStringz(archivePath), toStringz(fileName), &audio_size);
    return LoadMusicStreamFromMemory(".MP3", cast(const(ubyte)*)audio_data, audio_size);
}

Texture2D[] loadArrowTextures() {
    Texture2D[] arrowTextures = new Texture2D[16];
    foreach (i; 0 .. 16) {
        uint arrowSize;
        char *arrow_data = get_file_data_from_archive("res/data.bin", toStringz("MC*-" ~ i.to!string() ~ ".png"), &arrowSize);
        Image arrowArrow = LoadImageFromMemory(".PNG", cast(const(ubyte)*)arrow_data, arrowSize);
        arrowTextures[i] = LoadTextureFromImage(arrowArrow);
        UnloadImage(arrowArrow);
    }
    return arrowTextures;
}

void fadeInEffect(int screenWidth, int screenHeight, Texture2D mapTextureAkenadai, Texture2D mapTextureShibahama, string currentArea) {
    float fadeAlpha = 255.0f; // Start fully opaque
    while (fadeAlpha > 0) {
        fadeAlpha -= 5; // Decrease alpha
        if (fadeAlpha < 0) fadeAlpha = 0;

        BeginDrawing();
        ClearBackground(Colors.RAYWHITE);
        drawMapTexture(screenWidth, screenHeight, mapTextureAkenadai, mapTextureShibahama, currentArea);
        DrawRectangle(0, 0, screenWidth, screenHeight, Color(0, 0, 0, cast(ubyte)fadeAlpha)); // Draw fade rectangle
        EndDrawing();
    }
}

Camera2D setupCamera(int screenWidth, int screenHeight) {
    Camera2D camera;
    camera.target = Vector2(screenWidth / 2.0f, screenHeight / 2.0f);
    camera.offset = Vector2(screenWidth / 2.0f, screenHeight / 2.0f);
    camera.rotation = 0.0f;
    camera.zoom = 1.0f;
    return camera;
}

void drawMapTexture(int screenWidth, int screenHeight, Texture2D mapTextureAkenadai, Texture2D mapTextureShibahama, string currentArea) {
    if (currentArea == "Shibahama") {
        DrawTexturePro(mapTextureShibahama, Rectangle(0, 0, cast(float)mapTextureShibahama.width, cast(float)mapTextureShibahama.height), Rectangle(0, 0, cast(float)screenWidth, cast(float)screenHeight), Vector2(0, 0), 0.0, Colors.WHITE);
    } else if (currentArea == "Akenadai") {
        DrawTexturePro(mapTextureAkenadai, Rectangle(0, 0, cast(float)mapTextureAkenadai.width, cast(float)mapTextureAkenadai.height), Rectangle(0, 0, cast(float)screenWidth, cast(float)screenHeight), Vector2(0, 0), 0.0, Colors.WHITE);
    }
}