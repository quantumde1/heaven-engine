module graphics.ui_drawing;

import raylib;
import variables;
import std.stdio;
import script;
import core.time;
import core.thread;
import std.string;

void showMainMenu(ref GameState currentGameState) {
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    
    // Load the font from the image
    Font menuFont = LoadFont("res/font.png");
    
    float fadeAlpha = 0.0f; // Start with 0 for fade-in effect
    // Load the logo texture
    Texture2D logoTexture = LoadTexture("res/logo.png");
    
    // Calculate the position for the logo
    int logoX = (screenWidth - logoTexture.width) / 2;
    int logoY = (screenHeight - logoTexture.height) / 2 - 50; // Slightly higher than center

    string[] menuOptions = ["Start Game", "Options", "Exit Game"];
    int selectedMenuIndex = 0;
    float scaleX = 1.0f;

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
            int textWidth = cast(int)MeasureTextEx(menuFont, toStringz(menuOptions[i]), 30, 0).x;
            int textX = (screenWidth - textWidth) / 2; // Center the text
            int textY = logoY + logoTexture.height + 30 + (30 * i); // Position below the logo

            // Apply fading to the text color
            Color fadedTextColor = Fade(textColor, fadeAlpha);
            DrawTextEx(menuFont, toStringz(menuOptions[i]), Vector2(textX, textY), 30, 0, fadedTextColor);
        }

        EndDrawing();
    }

    while (!WindowShouldClose()) {
        BeginDrawing();
        ClearBackground(Colors.BLACK);

        // Draw the logo
        DrawTexture(logoTexture, logoX, logoY, Colors.WHITE);

        // Draw the menu options
        for (int i = 0; i < menuOptions.length; i++) {
            Color textColor = (i == selectedMenuIndex) ? Colors.LIGHTGRAY : Colors.GRAY;
            int textWidth = cast(int)MeasureTextEx(menuFont, toStringz(menuOptions[i]), 30, 0).x;
            int textX = (screenWidth - textWidth) / 2; // Center the text
            int textY = logoY + logoTexture.height + 30 + (30 * i); // Position below the logo

            DrawTextEx(menuFont, toStringz(menuOptions[i]), Vector2(textX, textY), 30, 0, textColor);
        }

        // Handle input for menu navigation
        if (IsKeyPressed(KeyboardKey.KEY_DOWN)) {
            selectedMenuIndex = cast(int)((selectedMenuIndex + 1) % menuOptions.length);
        }

        if (IsKeyPressed(KeyboardKey.KEY_UP)) {
            selectedMenuIndex = cast(int)((selectedMenuIndex - 1 + menuOptions.length) % menuOptions.length);
        }

        if (IsKeyPressed(KeyboardKey.KEY_ENTER) || IsKeyPressed(KeyboardKey.KEY_SPACE)) {
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
                            int textWidth = cast(int)MeasureTextEx(menuFont, toStringz(menuOptions[i]), 30, 0).x;
                            int textX = (screenWidth - textWidth) / 2; // Center the text
                            int textY = menuOptionYPositions[i]; // Use the stored Y position

                            // Apply fading to the text color
                            Color fadedTextColor = Fade(textColor, fadeAlpha);
                            DrawTextEx(menuFont, toStringz(menuOptions[i]), Vector2(textX, textY), 30, 0, fadedTextColor);
                        }

                        EndDrawing();
                    }
                    currentGameState = GameState.InGame;
                    return;
                case 1:
                    // Handle options menu
                    return;
                case 2:
                    currentGameState = GameState.Exit;
                    return;
                default:
                    break;
            }
        }

        EndDrawing();
    }
    UnloadTexture(logoTexture);
    UnloadFont(menuFont);
}
