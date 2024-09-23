module graphics.ui_drawing;

import graphics.main_loop;
import graphics.cubes;
import dialogs.dialog_system;
import raylib;
import std.typecons;
import variables;
import std.stdio;
import script;
import core.time;
import core.thread;

void showMainMenu(ref GameState currentGameState) {
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    int menuWidth = screenWidth / 5;
    int menuHeight = screenHeight / 10;
    int buttonPadding = 10;

    // Calculate the position of the menu in the bottom right corner
    int menuX = screenWidth - menuWidth - 10;
    int menuY = screenHeight - (menuHeight + buttonPadding) * 3 - 10;
    string[] menuOptions = ["Start Game", "Options", "Exit Game"];
    int selectedMenuIndex = 0;
    Music menuMusic;
    Music btnMenuMusic;

    // Load and play the menu music
    if (isAudioEnabled()) {
        menuMusic = LoadMusicStream("res/menu_music.mp3");
        PlayMusicStream(menuMusic);
        btnMenuMusic = LoadMusicStream("res/menu_btn_sfx.wav");
    }

    int animFrames = 0;
    bool isGifLoaded = false;
    Image imScarfyAnim;

    // Loading indicator variables
    int loadingBarWidth = screenWidth;
    int loadingBarHeight = 25;
    int loadingBarX = 0;
    int loadingBarY = screenHeight - loadingBarHeight - 10; // Position the bar 10 pixels from the bottom
    float loadingProgress = 0.0f;
    float loadingBarAlpha = 1.0f;
    version (Posix) {
    auto loadGifThread = new Thread({
        imScarfyAnim = LoadImageAnim("res/menu_background.gif", &animFrames);
        isGifLoaded = true;
    });
    }
    version (Windows) {
         auto loadGifThread = new Thread({
        imScarfyAnim = LoadImageAnim("hui.siegheil", &animFrames);
        isGifLoaded = true;
    });
    }
    loadGifThread.start();

    Texture2D texScarfyAnim = {0};
    int nextFrameDataOffset = 0;
    int currentAnimFrame = 0;
    int frameDelay = 2;
    int frameCounter = 0;
    float scaleX = 1.0f;
    float splashFadeAlpha = 0.0f;
    float fadeAlpha = 1.0f;
    bool loadingBarComplete = false;
    int posY = GetScreenHeight() - 20 - 40;
    while (!WindowShouldClose()) {
        frameCounter++;
        if (frameCounter >= frameDelay) {
            currentAnimFrame++;
            if (currentAnimFrame >= animFrames) currentAnimFrame = 0;

            nextFrameDataOffset = imScarfyAnim.width * imScarfyAnim.height * 4 * currentAnimFrame;
            if (texScarfyAnim.id != 0) {
                UpdateTexture(texScarfyAnim, imScarfyAnim.data + nextFrameDataOffset);
            }
            frameCounter = 0;
        }

        BeginDrawing();
        ClearBackground(Colors.BLACK);

        if (!isGifLoaded) {
            loadingProgress += 0.006f;
            if (loadingProgress >= 1.0f) {
                loadingProgress = 1.0f;
                loadingBarComplete = true;
            }
            DrawRectangle(loadingBarX, loadingBarY, loadingBarWidth, loadingBarHeight, Fade(Colors.DARKGRAY, loadingBarAlpha));
            DrawRectangle(loadingBarX, loadingBarY, cast(int)(loadingBarWidth * loadingProgress), loadingBarHeight, Fade(Colors.GREEN, loadingBarAlpha));
            DrawText("Loading...", loadingBarX + loadingBarWidth / 2 - MeasureText("Loading...", 20) / 2, loadingBarY - 30, 20, Colors.WHITE);
        } else {
            if (loadingBarComplete && loadingBarAlpha > 0.0f) {
                loadingBarAlpha -= 0.02f; // Adjust the decrement value to control the speed of the fade
            }

            if (texScarfyAnim.id == 0) {
                texScarfyAnim = LoadTextureFromImage(imScarfyAnim);
                scaleX = cast(float)screenWidth / texScarfyAnim.width;
            }

            if (isAudioEnabled()) {
                UpdateMusicStream(menuMusic);
            }
            DrawTextureEx(texScarfyAnim, Vector2(0, 0), 0.0f, scaleX, Fade(Colors.WHITE, splashFadeAlpha));

            if (splashFadeAlpha < 1.0f) {
                splashFadeAlpha += 0.04f;
            } else {
                if (IsGamepadAvailable(0)) {
                    int buttonSize = 30;
                    int circleCenterX = 40 + buttonSize / 2;
                    int circleCenterY = posY + buttonSize / 2;
                    int textYOffset = 7; // Adjust this offset based on your font and text size
                    DrawCircle(circleCenterX, circleCenterY, buttonSize / 2, Colors.GREEN);
                    DrawText(cast(char*)("A"), circleCenterX - 5, circleCenterY - textYOffset, 20, Colors.BLACK);
                    DrawText(cast(char*)(" to open"), 40 + buttonSize + 5, posY, 20, Colors.BLACK);
                } else {
                    int fontSize = 20;
                    DrawText(cast(char*)("Press enter to start"), 40, posY, fontSize, Colors.BLACK);
                }
                for (int i = 0; i < menuOptions.length; i++) {
                    Color buttonColor = (i == selectedMenuIndex) ? Colors.DARKGRAY : Colors.LIGHTGRAY;
                    DrawRectangleRounded(Rectangle(menuX, menuY + (menuHeight + buttonPadding) * i, menuWidth, menuHeight), 0.2f, 10, buttonColor);
                    DrawText(cast(char*)menuOptions[i], menuX + 10, menuY + 10 + (menuHeight + buttonPadding) * i, 20, Colors.WHITE);
                }

                if (isAudioEnabled()) {
                    UpdateMusicStream(btnMenuMusic);
                }

                if (IsKeyPressed(KeyboardKey.KEY_DOWN) || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN)) {
                    if (isAudioEnabled()) {
                        PlayMusicStream(btnMenuMusic);
                    }
                    selectedMenuIndex = cast(int)((selectedMenuIndex + 1) % menuOptions.length);
                }

                if (IsKeyPressed(KeyboardKey.KEY_UP) || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP)) {
                    if (isAudioEnabled()) {
                        PlayMusicStream(btnMenuMusic);
                    }
                    selectedMenuIndex = cast(int)((selectedMenuIndex - 1 + menuOptions.length) % menuOptions.length);
                }

                if (IsKeyReleased(KeyboardKey.KEY_UP) || IsKeyReleased(KeyboardKey.KEY_DOWN)) {
                    if (isAudioEnabled()) {
                        auto stopThread = new Thread({
                            Thread.sleep(dur!"msecs"(150));
                            StopMusicStream(btnMenuMusic);
                        });
                        stopThread.start();
                    }
                } else if (IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP) || 
                IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN)) {
                    auto stopThread = new Thread({
                            Thread.sleep(dur!"msecs"(200));
                            StopMusicStream(btnMenuMusic);
                        });
                        stopThread.start();
                }

                if (IsKeyPressed(KeyboardKey.KEY_ENTER) || IsKeyPressed(KeyboardKey.KEY_SPACE) || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) {
                    switch (selectedMenuIndex) {
                        case 0:
                            while (fadeAlpha > 0.0f) {
                                fadeAlpha -= 0.04f;
                                BeginDrawing();
                                ClearBackground(Colors.BLACK);
                                DrawTextureEx(texScarfyAnim, Vector2(0, 0), 0.0f, scaleX, Fade(Colors.WHITE, fadeAlpha));
                                EndDrawing();
                            }
                            currentGameState = GameState.InGame;
                            if (isAudioEnabled()) {
                                StopMusicStream(menuMusic);
                                UnloadMusicStream(menuMusic);
                            }
                            UnloadTexture(texScarfyAnim);
                            UnloadImage(imScarfyAnim);
                            return;
                        case 1:
                            break;
                        case 2:
                            currentGameState = GameState.Exit;
                            return;
                        default:
                            break;
                    }
                }
            }

            // Draw the loading bar even after GIF is loaded for the fade effect
            if (loadingBarAlpha > 0.0f) {
                DrawRectangle(loadingBarX, loadingBarY, loadingBarWidth, loadingBarHeight, Fade(Colors.DARKGRAY, loadingBarAlpha));
                DrawRectangle(loadingBarX, loadingBarY, cast(int)(loadingBarWidth * loadingProgress), loadingBarHeight, Fade(Colors.GREEN, loadingBarAlpha));
                DrawText("Loading...", loadingBarX + loadingBarWidth / 2 - MeasureText("Loading...", 20) / 2, loadingBarY - 30, 20, Fade(Colors.WHITE, loadingBarAlpha));
            }
        }

        EndDrawing();
    }

    if (isAudioEnabled()) {
        UnloadMusicStream(menuMusic);
        UnloadMusicStream(btnMenuMusic);
    }
    UnloadTexture(texScarfyAnim);
    UnloadImage(imScarfyAnim);
}

void displayDialogs(Nullable!Cube collidedCube, char dlg, ref bool allowControl, ref bool showDialog, ref bool allow_exit_dialog, ref string name) {
    bool isCubeNotNull = !collidedCube.isNull;
    import std.string : toStringz;
    int posY = GetScreenHeight() - 20 - 40;
    // Check if cube collision is not null
    if (isCubeNotNull) {
        if (!showDialog && allow_exit_dialog && !inBattle) {
            if (IsGamepadAvailable(0)) {
                int buttonSize = 30;
                int circleCenterX = 40 + buttonSize / 2;
                int circleCenterY = posY + buttonSize / 2;
                int textYOffset = 7; // Adjust this offset based on your font and text size
                DrawCircle(circleCenterX, circleCenterY, buttonSize / 2, Colors.RED);
                DrawText(("B"), circleCenterX - 5, circleCenterY - textYOffset, 20, Colors.BLACK);
                DrawText((" to dialog"), 40 + buttonSize + 5, posY, 20, Colors.BLACK);
            } else {
                int fontSize = 20;
                DrawText(toStringz("Press "~dlg~" for dialog"), 40, posY, fontSize, Colors.BLACK);
            }
        }

        // If all correct, show dialog from script with all needed text, name, emotion etc
        if (IsKeyPressed(dlg) || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT)) {
            if (allow_exit_dialog) {
                allow_exit_dialog = false;
                allowControl = false;
                name = collidedCube.get.name;
                showDialog = true;
                // Set the global variables to the current cube's dialog
                name_global = collidedCube.get.name;
                message_global = collidedCube.get.text;
                emotion_global = collidedCube.get.emotion;
                pageChoice_glob = collidedCube.get.choicePage;
            }
        }
    }

    // If dialog is not ended (not all text pages showed), show up "Press enter for continue" for showing next page of text
    if (showDialog && isCubeNotNull) {
        display_dialog(name_global, emotion_global, message_global, pageChoice_glob);
    }
}
