module graphics.ui_drawing;

import raylib;
import variables;
import std.stdio;
import script;
import core.time;
import core.thread;
import std.string;
import graphics.main_loop;

void showMainMenu(ref GameState currentGameState) {
    string[] menuOptions;
    if (isAudioEnabled()) {
        audioEnabled = true;
        menuOptions = ["Start Game", "Language: English", "Shaders: On", "Sound: On", "FPS: 60", "Exit Game"];
    } else {
        audioEnabled = false;
        menuOptions = ["Start Game", "Language: English", "Shaders: On", "Sound: Off", "FPS: 60", "Exit Game"];
    }
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    char* musicpathMenu = cast(char*)("main_menu.mp3");
    Music musicMenu;
    uint audio_size;
    char *audio_data = get_file_data_from_archive("res/data.bin", musicpathMenu, &audio_size);
    musicMenu = LoadMusicStreamFromMemory(".mp3", cast(const(ubyte)*)audio_data, audio_size);
    PlayMusicStream(musicMenu);
    float fadeAlpha = 0.0f; // Start with 0 for fade-in effect
    uint image_size;
    char *image_data_logo = get_file_data_from_archive("res/data.bin", "logo.png", &image_size);
    Texture2D logoTexture = LoadTextureFromImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data_logo, image_size));
    UnloadImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data_logo, image_size));
    char *image_data = get_file_data_from_archive("res/data.bin", "logo_background.png", &image_size);
    Texture2D logoBackTexture = LoadTextureFromImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size));
    UnloadImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size));
    
    int logoX = (screenWidth - logoTexture.width) / 2;
    int logoY = (screenHeight - logoTexture.height) / 2 - 50; // Slightly higher than center
    // Calculate the center position for the logo and background
    int logoXback = (screenWidth - logoBackTexture.width) / 2; // Center the background
    int logoYback = (screenHeight - logoBackTexture.height) / 2 - 50; // Center the background

    int selectedMenuIndex = 0;
    float scaleX = 1.0f;
    // Language toggle variable
    bool isEnglish = true;

    Color darkTint = Color( 80, 80, 80, 255 ); // Dark gray color
    // Fade-in effect
    while (fadeAlpha < 1.0f) {
        fadeAlpha += 0.02f; // Increase alpha value for fading in
        if (fadeAlpha > 1.0f) fadeAlpha = 1.0f; // Clamp to 1.0
        BeginDrawing();
        ClearBackground(Colors.BLACK);
        // Draw the logo with fading
        DrawTextureEx(logoBackTexture, Vector2(logoXback, logoYback), 0.0f, scaleX, Fade(darkTint, fadeAlpha));
        DrawTextureEx(logoTexture, Vector2(logoX, logoY), 0.0f, scaleX, Fade(Colors.WHITE, fadeAlpha));
        // Draw the menu options with fading
        for (int i = 0; i < menuOptions.length; i++) {
            Color textColor = (i == selectedMenuIndex) ? Colors.LIGHTGRAY : Colors.GRAY;
            int textWidth = cast(int)MeasureTextEx(fontdialog, toStringz(menuOptions[i]), 30, 0).x;
            int textX = (screenWidth - textWidth) / 2; // Center the text
            int textY = logoY + logoTexture.height + 100 + (30 * i); // Position below the logo

            // Apply fading to the text color
            Color fadedTextColor = Fade(textColor, fadeAlpha);
            DrawTextEx(fontdialog, toStringz(menuOptions[i]), Vector2(textX, textY), 30, 0, fadedTextColor);
        }
        int textWidth = cast(int)MeasureTextEx(fontdialog, toStringz("Shin Megami Tensei is copyright of ATLUS, Co. Ltd. -reload- developed by Underlevel Productions"), 20, 0).x;
        int textYlol = cast(int)(logoY + logoTexture.height + 100 + (30 * menuOptions.length) + 50); // Position below the logo
        int textX = (screenWidth - textWidth) / 2; // Center the text
        DrawTextEx(fontdialog, "Shin Megami Tensei is copyright of ATLUS, Co. Ltd. -reload- developed by Underlevel Productions", Vector2(textX, textYlol), 20, 0, Fade(Colors.WHITE, fadeAlpha));
        EndDrawing();
    }
    while (!WindowShouldClose()) {
        UpdateMusicStream(musicMenu);
        BeginDrawing();
        ClearBackground(Colors.BLACK);
        if (IsKeyPressed(KeyboardKey.KEY_F3) && !rel) {
            showDebug = !showDebug;
        }
        // Draw Debug Information
        if (showDebug) {
            drawDebugInfo(cubePosition, currentGameState, playerHealth, cameraAngle, playerStepCounter, 
            encounterThreshold, inBattle);
        }
        // Draw the logo
        DrawTexture(logoBackTexture, logoXback, logoYback, darkTint);
        DrawTexture(logoTexture, logoX, logoY, Colors.WHITE);

        // Draw the menu options
        for (int i = 0; i < menuOptions.length; i++) {
            Color textColor = (i == selectedMenuIndex) ? Colors.LIGHTGRAY : Colors.GRAY;
            int textWidth = cast(int)MeasureTextEx(fontdialog, toStringz(menuOptions[i]), 30, 0).x;
            int textX = (screenWidth - textWidth) / 2; // Center the text
            int textY = logoY + logoTexture.height + 100 + (30 * i); // Position below the logo

            DrawTextEx(fontdialog, toStringz(menuOptions[i]), Vector2(textX, textY), 30, 0, textColor);
        }
        int textWidthLol = cast(int)MeasureTextEx(fontdialog, toStringz("Shin Megami Tensei is copyright of ATLUS, Co. Ltd. -reload- developed by Underlevel Productions"), 20, 0).x;
        int textYlol = cast(int)(logoY + logoTexture.height + 100 + (30 * menuOptions.length) + 50); // Position below the logo
        
        DrawTextEx(fontdialog, "Shin Megami Tensei is copyright of ATLUS, Co. Ltd. -reload- developed by Underlevel Productions", Vector2((screenWidth - textWidthLol) /2, textYlol), 20, 0, Colors.WHITE);
        // Handle input for menu navigation
        if (IsKeyPressed(KeyboardKey.KEY_DOWN) || IsGamepadButtonPressed(gamepadInt, 
        GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN)) {
            selectedMenuIndex = cast(int)((selectedMenuIndex + 1) % menuOptions.length);
        }

        if (IsKeyPressed(KeyboardKey.KEY_UP) || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP)) {
            selectedMenuIndex = cast(int)((selectedMenuIndex - 1 + menuOptions.length) % menuOptions.length);
        }

        switch (selectedMenuIndex) {
        // Handle language toggle
        case 1:
            if (IsKeyPressed(KeyboardKey.KEY_RIGHT) || IsGamepadButtonPressed(gamepadInt, 
    GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT)) {
                isEnglish = false;
                menuOptions[1] = "Language: Russian"; // Change to Russian
            }
            if (IsKeyPressed(KeyboardKey.KEY_LEFT) || IsGamepadButtonPressed(gamepadInt, 
            GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT)) {
                isEnglish = true;
                menuOptions[1] = "Language: English"; // Change to English
            }
            break;

        case 2:
            if (IsKeyPressed(KeyboardKey.KEY_RIGHT) || IsGamepadButtonPressed(gamepadInt, 
    GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT)) {
                shaderEnabled = false;
                menuOptions[2] = "Shaders: Off";
            }
            if (IsKeyPressed(KeyboardKey.KEY_LEFT) || IsGamepadButtonPressed(gamepadInt, 
    GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT)) {
                shaderEnabled = true;
                menuOptions[2] = "Shaders: On";
            }
            break;
        case 3:
            if (IsKeyPressed(KeyboardKey.KEY_RIGHT) || IsGamepadButtonPressed(gamepadInt, 
    GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT)) {
                audioEnabled = false;
                menuOptions[3] = "Sound: Off";
            }
            if (IsKeyPressed(KeyboardKey.KEY_LEFT) || IsGamepadButtonPressed(gamepadInt, 
            GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT)) {
                audioEnabled = true;
                menuOptions[3] = "Sound: On";
            }
            break;
        case 4:
            if (IsKeyPressed(KeyboardKey.KEY_RIGHT) || IsGamepadButtonPressed(gamepadInt, 
    GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT)) {
                FPS = 30;
                SetTargetFPS(FPS);
                menuOptions[4] = "FPS: 30"; 
            }
            if (IsKeyPressed(KeyboardKey.KEY_LEFT) || IsGamepadButtonPressed(gamepadInt, 
            GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT)) {
                FPS = 60;
                SetTargetFPS(FPS);
                menuOptions[4] = "FPS: 60";
            }
            break;
        default:
            break;
        }
        if (IsKeyPressed(KeyboardKey.KEY_ENTER) || IsKeyPressed(KeyboardKey.KEY_SPACE) || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) {
            switch (selectedMenuIndex) {
                case 0:
                    // Calculate the positions for the menu options
                    int[] menuOptionYPositions = new int[menuOptions.length];
                    for (int i = 0; i < menuOptions.length; i++) {
                        menuOptionYPositions[i] = logoY + logoTexture.height + 100 + (30 * i);
                    }

                    // Fade out effect when starting the game
                    while (fadeAlpha > 0.0f) {
                        fadeAlpha -= 0.04f; // Decrease the alpha value for fading
                        if (fadeAlpha < 0.0f) fadeAlpha = 0.0f; // Clamp to 0.0

                        BeginDrawing();
                        ClearBackground(Colors.BLACK);

                        // Draw the logo at its stored position with fading
                        DrawTextureEx(logoBackTexture, Vector2(logoXback, logoYback), 0.0f, scaleX, Fade(darkTint, fadeAlpha));
                        DrawTextureEx(logoTexture, Vector2(logoX, logoY), 0.0f, scaleX, Fade(Colors.WHITE, fadeAlpha));
                        for (int i = 0; i < menuOptions.length; i++) {
                            Color textColor = (i == selectedMenuIndex) ? Colors.LIGHTGRAY : Colors.GRAY;
                            int textWidth = cast(int)MeasureTextEx(fontdialog, toStringz(menuOptions[i]), 30, 0).x;
                            int textX = (screenWidth - textWidth) / 2; // Center the text
                            int textY = menuOptionYPositions[i]; // Use the stored Y position

                            // Apply fading to the text color
                            Color fadedTextColor = Fade(textColor, fadeAlpha);
                            DrawTextEx(fontdialog, toStringz(menuOptions[i]), Vector2(textX, textY), 30, 0, fadedTextColor);
                        }
                        DrawTextEx(fontdialog, "Shin Megami Tensei is copyright of ATLUS, Co. Ltd. -reload- developed by Underlevel Productions", Vector2((screenWidth - textWidthLol)/2, textYlol), 20, 0, Fade(Colors.WHITE, fadeAlpha));
                        EndDrawing();
                    }
                    UnloadTexture(logoTexture);
                    UnloadTexture(logoBackTexture);
                    UnloadMusicStream(musicMenu);
                    currentGameState = GameState.InGame;
                    return;
                
                case 5:
                    currentGameState = GameState.Exit;
                    UnloadTexture(logoTexture);
                    UnloadTexture(logoBackTexture);
                    UnloadMusicStream(musicMenu);
                    return;
                default:
                    break;
            }
        }

        EndDrawing();
    }
    UnloadTexture(logoTexture);
    UnloadMusicStream(musicMenu);
    UnloadTexture(logoBackTexture);
}