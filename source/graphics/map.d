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

void openMap(string location, string area) {
    mapOpened = true;
    const int screenWidth = GetScreenWidth();
    const int screenHeight = GetScreenHeight();
    const int rectWidth = 100;
    const int rectHeight = 100;
    int selectedMenuIndex = 0;
    int rectX, rectY;
    float timeElapsed = 0.0f;
    float animationSpeed = 0.07f;
    // Define menu options and their corresponding positions
    string[] menuOptions_akenadai = ["Home", "Astro Museum", "Akane Mall"];
    string[] menuOptions_shibahama = ["Shibahama Core", "Goumaden", "South Parking"];
    string[] locationNames_akenadai = ["home", "planetarium", "akanemall"];
    string[] locationNames_shibahama = ["core", "goumaden", "garage"];

    // Set initial rectangle position based on location
    switch (location) {
        case "home": selectedMenuIndex = 0; break;
        case "planetarium": selectedMenuIndex = 1; break;
        case "akanemall": selectedMenuIndex = 2; break;
        default: break;
    }
    
    // Load textures and music
    uint image_size;
    char *image_data = get_file_data_from_archive("res/data.bin", "akenadai_map.png", &image_size);
    Texture2D mapTextureAkenadai = LoadTextureFromImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size));
    UnloadImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size));

    image_data = get_file_data_from_archive("res/data.bin", "shibahama_map.png", &image_size);
    Texture2D mapTextureShibahama = LoadTextureFromImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size));
    uint audio_size;
    char *audio_data = get_file_data_from_archive("res/data.bin", "map_music.mp3", &audio_size);
    Music musicMenu;

    if (audioEnabled) {
        musicMenu = LoadMusicStreamFromMemory(".MP3", cast(const(ubyte)*)audio_data, audio_size);
        PlayMusicStream(musicMenu);
    }

    // Load textures for animation
    Texture2D[] arrowTextures = new Texture2D[16];
    foreach (i; 0 .. 16) {
        uint arrowSize;
        char *arrow_data = get_file_data_from_archive("res/data.bin", toStringz("MC*-" ~ i.to!string() ~ ".png"), &arrowSize);
        Image arrowArrow = LoadImageFromMemory(".PNG", cast(const(ubyte)*)arrow_data, arrowSize);
        arrowTextures[i] = LoadTextureFromImage(arrowArrow);
        UnloadImage(arrowArrow);
    }
    
    int currentFrame = 0;
    string currentArea = "Akenadai"; // Default area
    string[] currentMenuOptions = menuOptions_akenadai;
    string[] currentLocationNames = locationNames_akenadai;

    // Initialize Camera2D
    Camera2D camera;
    camera.target = Vector2(screenWidth / 2.0f, screenHeight / 2.0f);
    camera.offset = Vector2(screenWidth / 2.0f, screenHeight / 2.0f);
    camera.rotation = 0.0f;
    camera.zoom = 1.0f;

    // Fade-in effect
    float fadeAlpha = 255.0f; // Start fully opaque
    while (fadeAlpha > 0) {
        fadeAlpha -= 5; // Decrease alpha
        if (fadeAlpha < 0) fadeAlpha = 0;

        BeginDrawing();
        ClearBackground(Colors.RAYWHITE);
        if (currentArea == "shibahama" || currentArea == "Shibahama") {
            currentArea = "Shibahama";
            DrawTexturePro(mapTextureShibahama, Rectangle(0, 0, cast(float)mapTextureShibahama.width, cast(float)mapTextureShibahama.height), Rectangle(0, 0, cast(float)screenWidth, cast(float)screenHeight), Vector2(0, 0), 0.0, Colors.WHITE);
        }
        if (currentArea == "akenadai" || currentArea == "Akenadai") {
            currentArea = "Akenadai";
            DrawTexturePro(mapTextureAkenadai, Rectangle(0, 0, cast(float)mapTextureAkenadai.width, cast(float)mapTextureAkenadai.height), Rectangle(0, 0, cast(float)screenWidth, cast(float)screenHeight), Vector2(0, 0), 0.0, Colors.WHITE);
        }
        // Draw fade rectangle
        DrawRectangle(0, 0, screenWidth, screenHeight, Color(0, 0, 0, cast(ubyte)fadeAlpha)); // Draw fade rectangle
        EndDrawing();
    }

    // Main game loop
    while (!WindowShouldClose()) {
        UpdateMusicStream(musicMenu);
        // Update animation frame
        timeElapsed += GetFrameTime();
        if (timeElapsed >= animationSpeed) {
            currentFrame = cast(int)((currentFrame + 1) % arrowTextures.length);
            timeElapsed = 0.0f;
        }

        // Handle area switching
        if (IsKeyPressed(KeyboardKey.KEY_TAB) || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_TRIGGER_1) || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_TRIGGER_2)) {
            currentArea = (currentArea == "Akenadai") ? "Shibahama" : "Akenadai";
            // Update current menu options based on the selected area
            if (currentArea == "Akenadai") {
                currentMenuOptions = menuOptions_akenadai;
                currentLocationNames = locationNames_akenadai;
            } else {
                currentMenuOptions = menuOptions_shibahama;
                currentLocationNames = locationNames_shibahama;
            }
            selectedMenuIndex = 0; // Reset selection when switching areas
        }

        // Draw area name
        DrawTextEx(fontdialog, toStringz(currentArea), Vector2(screenWidth / 2 - MeasureText(toStringz(currentArea), 30) / 2, 10), 30, 0, Colors.WHITE);

        // Handle input for menu navigation
        if (IsKeyPressed(KeyboardKey.KEY_DOWN) || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN)) {
            selectedMenuIndex = cast(int)((selectedMenuIndex + 1) % currentMenuOptions.length);
        }
        if (IsKeyPressed(KeyboardKey.KEY_UP) || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP)) {
            selectedMenuIndex = cast(int)((selectedMenuIndex - 1 + currentMenuOptions.length) % currentMenuOptions.length);
        }
        switch (currentArea) {
            case "Akenadai":
                if (selectedMenuIndex == 0) {

                }
                if (selectedMenuIndex == 1) {

                }
                if (selectedMenuIndex == 2) {

                }
                break;
            case "Shibahama":
                if (selectedMenuIndex == 0) {
                    rectX = 373;
                    rectY = 790;
                }
                if (selectedMenuIndex == 1) {
                    rectX = 773;
                    rectY = 390;
                }
                if (selectedMenuIndex == 2) {
                    rectX = 806;
                    rectY = 810;
                }
                if (selectedMenuIndex == 3) {
                    rectX = 1419;
                    rectY = 220;
                }
                break;
            default:
                break;
        }
        // Draw the map texture
        BeginMode2D(camera);
        ClearBackground(Colors.RAYWHITE);
        if (currentArea == "shibahama" || currentArea == "Shibahama") {
        // Draw the map texture
            DrawTexturePro(mapTextureShibahama, Rectangle(0, 0, cast(float)mapTextureShibahama.width, cast(float)mapTextureShibahama.height), Rectangle(0, 0, cast(float)screenWidth, cast(float)screenHeight), Vector2(0, 0), 0.0, Colors.WHITE);
        }
        if (currentArea == "akenadai" || currentArea == "Akenadai") {
            DrawTexturePro(mapTextureAkenadai, Rectangle(0, 0, cast(float)mapTextureAkenadai.width, cast(float)mapTextureAkenadai.height), Rectangle(0, 0, cast(float)screenWidth, cast(float)screenHeight), Vector2(0, 0), 0.0, Colors.WHITE);
        }
        DrawRectangle(0, 0, screenWidth / 2, 50, Color(100, 54, 65, 255));
        DrawTextEx(fontdialog, toStringz(currentArea), Vector2(20, 10), 30, 0, Colors.WHITE);

        // Draw the second rectangle in the second half of the screen
        DrawRectangle(screenWidth / 2, 0, screenWidth / 2, 50, Color(80, 54, 65, 255));
        DrawTextEx(fontdialog, toStringz((currentArea == "Akenadai") ? "Shibahama" : "Akenadai"), Vector2(screenWidth / 2 + 20, 10), 30, 0, Colors.GRAY);

        // Draw allowed locations
        for (int i = 0; i < currentMenuOptions.length; i++) {
            Color buttonColor = (i == selectedMenuIndex) ? Color(0, 0, 0, 210) : Color(0, 0, 0, 150);
            DrawRectangleRounded(Rectangle(10, 60 + (30 * i), 200, 30), 0.03f, 16, buttonColor);
            DrawTextEx(fontdialog, toStringz(currentMenuOptions[i]), Vector2(20, 64 + (30 * i)), 20, 1.0f, Colors.WHITE);
        }
        DrawRectangleRoundedLines(Rectangle(10, 60, 200, 30 * currentMenuOptions.length), 0.03f, 16, 3.0f, Color(100, 54, 65, 255)); // Outline

        // Draw animated arrow
        float scaleFactor = 0.7f; // Scale factor
        DrawTexturePro(
            arrowTextures[currentFrame],
            Rectangle(0, 0, cast(float)arrowTextures[currentFrame].width, cast(float)arrowTextures[currentFrame].height),
            Rectangle(rectX, rectY, rectWidth * scaleFactor, rectHeight * scaleFactor),
            Vector2(0, 0),
            0.0,
            Colors.WHITE
        );
        int posY = GetScreenHeight() - 20 - 40;
        if (IsGamepadAvailable(gamepadInt)) {
            int fontSize = 20;
            DrawText(toStringz("Press L1/R1/RB/LB for switching area"), 40, posY, fontSize, Colors.BLACK);
        } else {
            int fontSize = 20;
            DrawText(toStringz("Press TAB for switching area"), 40, posY, fontSize, Colors.BLACK);
        }
        // End drawing with the camera
        EndMode2D();
        EndDrawing();

        // Handle selection
        if (IsKeyPressed(KeyboardKey.KEY_ENTER) || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) {
            locationname = currentLocationNames[selectedMenuIndex]; // Get the location name
            float fadeOutAlpha = 0.0f; // Start fully transparent
            while (fadeOutAlpha < 255) {
                fadeOutAlpha += 5; // Increase alpha
                if (fadeOutAlpha > 255) fadeOutAlpha = 255;

                BeginDrawing();
                ClearBackground(Colors.RAYWHITE);
                if (currentArea == "shibahama" || currentArea == "Shibahama") {
                    DrawTexturePro(mapTextureShibahama, Rectangle(0, 0, cast(float)mapTextureShibahama.width, cast(float)mapTextureShibahama.height), Rectangle(0, 0, cast(float)screenWidth, cast(float)screenHeight), Vector2(0, 0), 0.0, Colors.WHITE);
                }
                if (currentArea == "akenadai" || currentArea == "Akenadai") {
                    DrawTexturePro(mapTextureAkenadai, Rectangle(0, 0, cast(float)mapTextureAkenadai.width, cast(float)mapTextureAkenadai.height), Rectangle(0, 0, cast(float)screenWidth, cast(float)screenHeight), Vector2(0, 0), 0.0, Colors.WHITE);
                }
                // Draw gray panel
                DrawRectangle(0, 0, screenWidth, 50, Color(100, 54, 65, 255));
                DrawTextEx(fontdialog, "Select destination", Vector2(20, 10), 30, 0, Colors.WHITE);
                
                // Draw allowed locations
                for (int i = 0; i < currentMenuOptions.length; i++) {
                    Color buttonColor = (i == selectedMenuIndex) ? Color(0, 0, 0, 210) : Color(0, 0, 0, 150);
                    DrawRectangleRounded(Rectangle(10, 60 + (30 * i), 200, 30), 0.03f, 16, buttonColor);
                    DrawTextEx(fontdialog, toStringz(currentMenuOptions[i]), Vector2(20, 64 + (30 * i)), 20, 1.0f, Colors.WHITE);
                }
                DrawRectangleRoundedLines(Rectangle(10, 60, 200, 30 * currentMenuOptions.length), 0.03f, 16, 3.0f, Color(100, 54, 65, 255)); // Outline
                
                // Draw fade rectangle
                DrawRectangle(0, 0, screenWidth, screenHeight, Color(0, 0, 0, cast(ubyte)fadeOutAlpha)); // Draw fade rectangle
                EndDrawing();
            }

            // Load the selected location
            //loadLocation(cast(char*)toStringz("res/" ~ locationname ~ ".glb"), 19.0f);
            isNewLocationNeeded = true;
            break; // Exit the loop after loading the location
        }
    }

    // Unload resources
    UnloadTexture(mapTextureAkenadai);
    UnloadTexture(mapTextureShibahama);
    if (audioEnabled) {
        UnloadMusicStream(musicMenu);
    }
    foreach (texture; arrowTextures) {
        UnloadTexture(texture);
    }
    mapOpened = false;
}