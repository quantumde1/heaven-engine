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
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    
    float fadeAlpha = 0.0f; // Start with 0 for fade-in effect
    Texture2D logoTexture = LoadTexture("res/logo.png");
    
    int logoX = (screenWidth - logoTexture.width) / 2;
    int logoY = (screenHeight - logoTexture.height) / 2 - 50; // Slightly higher than center

    int selectedMenuIndex = 0;
    float scaleX = 1.0f;
    string[] menuOptions;
    // Language toggle variable
    bool isEnglish = true;
    
    if (isAudioEnabled()) {
        audioEnabled = true;
        menuOptions = ["Start Game", "Language: English", "Shaders: On", "Sound: On", "Exit Game"];
    } else {
        audioEnabled = false;
        menuOptions = ["Start Game", "Language: English", "Shaders: On", "Sound: Off", "Exit Game"];
    }
    
    // Fade-in effect
    while (fadeAlpha < 1.0f) {
        fadeAlpha += 0.02f; // Increase alpha value for fading in
        if (fadeAlpha > 1.0f) fadeAlpha = 1.0f; // Clamp to 1.0

        BeginDrawing();
        ClearBackground(Colors.BLACK);

        // Draw the logo with fading
        DrawTextureEx(logoTexture, Vector2(logoX, logoY), 0.0f, scaleX, Fade(Colors.WHITE, fadeAlpha));

        // Draw the menu options with fading
        for (int i = 0; i < menuOptions.length; i++) {
            Color textColor = (i == selectedMenuIndex) ? Colors.LIGHTGRAY : Colors.GRAY;
            int textWidth = cast(int)MeasureTextEx(fontdialog, toStringz(menuOptions[i]), 30, 0).x;
            int textX = (screenWidth - textWidth) / 2; // Center the text
            int textY = logoY + logoTexture.height + 30 + (30 * i); // Position below the logo

            // Apply fading to the text color
            Color fadedTextColor = Fade(textColor, fadeAlpha);
            DrawTextEx(fontdialog, toStringz(menuOptions[i]), Vector2(textX, textY), 30, 0, fadedTextColor);
        }

        EndDrawing();
    }

    while (!WindowShouldClose()) {
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
        DrawTexture(logoTexture, logoX, logoY, Colors.WHITE);

        // Draw the menu options
        for (int i = 0; i < menuOptions.length; i++) {
            Color textColor = (i == selectedMenuIndex) ? Colors.LIGHTGRAY : Colors.GRAY;
            int textWidth = cast(int)MeasureTextEx(fontdialog, toStringz(menuOptions[i]), 30, 0).x;
            int textX = (screenWidth - textWidth) / 2; // Center the text
            int textY = logoY + logoTexture.height + 30 + (30 * i); // Position below the logo

            DrawTextEx(fontdialog, toStringz(menuOptions[i]), Vector2(textX, textY), 30, 0, textColor);
        }

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
                menuOptions[2] = "Shaders: Off"; // Change to Russian
            }
            if (IsKeyPressed(KeyboardKey.KEY_LEFT) || IsGamepadButtonPressed(gamepadInt, 
    GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT)) {
                shaderEnabled = true;
                menuOptions[2] = "Shaders: On"; // Change to English
            }
            break;
        case 3:
            if (IsKeyPressed(KeyboardKey.KEY_RIGHT) || IsGamepadButtonPressed(gamepadInt, 
    GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT)) {
                audioEnabled = false;
                menuOptions[3] = "Sound: Off"; // Change to Russian
            }
            if (IsKeyPressed(KeyboardKey.KEY_LEFT) || IsGamepadButtonPressed(gamepadInt, 
            GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT)) {
                audioEnabled = true;
                menuOptions[3] = "Sound: On"; // Change to English
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
                        menuOptionYPositions[i] = logoY + logoTexture.height + 30 + (30 * i);
                    }

                    // Fade out effect when starting the game
                    while (fadeAlpha > 0.0f) {
                        fadeAlpha -= 0.04f; // Decrease the alpha value for fading
                        if (fadeAlpha < 0.0f) fadeAlpha = 0.0f; // Clamp to 0.0

                        BeginDrawing();
                        ClearBackground(Colors.BLACK);

                        // Draw the logo at its stored position with fading
                        DrawTextureEx(logoTexture, Vector2(logoX, logoY), 0.0f, scaleX, Fade(Colors.WHITE, fadeAlpha));

                        // Draw the menu options at their stored positions with fading
                        for (int i = 0; i < menuOptions.length; i++) {
                            Color textColor = (i == selectedMenuIndex) ? Colors.LIGHTGRAY : Colors.GRAY;
                            int textWidth = cast(int)MeasureTextEx(fontdialog, toStringz(menuOptions[i]), 30, 0).x;
                            int textX = (screenWidth - textWidth) / 2; // Center the text
                            int textY = menuOptionYPositions[i]; // Use the stored Y position

                            // Apply fading to the text color
                            Color fadedTextColor = Fade(textColor, fadeAlpha);
                            DrawTextEx(fontdialog, toStringz(menuOptions[i]), Vector2(textX, textY), 30, 0, fadedTextColor);
                        }

                        EndDrawing();
                    }
                    currentGameState = GameState.InGame;
                    return;
                
                case 4:
                    currentGameState = GameState.Exit;
                    return;
                default:
                    break;
            }
        }

        EndDrawing();
    }
    UnloadTexture(logoTexture);
}