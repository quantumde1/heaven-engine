module graphics.map;

import raylib;
import graphics.scene;
import graphics.cubes;
import std.stdio;
import std.string;
import graphics.main_loop;
import script;
import variables;
import std.conv;

void openMap(Camera3D camera, Vector3 cubeSecPosition, float camAngle, Cube[] cubes, string location) {
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    int selectedMenuIndex;
    int rectWidth = 100;
    int rectHeight = 100;
    int rectX, rectY;

    // Set initial rectangle position and selected menu index based on location
    switch (location) {
        case "schl":
            rectX = screenWidth * 2 / 3;
            rectY = screenHeight * 3 / 4;
            selectedMenuIndex = 2;
            break;
        case "home":
            rectX = screenHeight / 7;
            rectY = screenWidth / 8;
            selectedMenuIndex = 3;
            break;
        case "area1":
            rectX = (screenWidth - screenHeight) / 2;
            rectY = screenWidth / 8;
            selectedMenuIndex = 0;
            break;
        case "area2":
            rectX = screenHeight - rectWidth - screenHeight / 4 + screenWidth / 3;
            rectY = screenWidth / 5 + screenHeight / 25;
            selectedMenuIndex = 1;
            break;
        default:
            break;
    }

    SetTargetFPS(60);
    int menuWidth = screenWidth / 5;
    int menuHeight = screenHeight / 10;
    int buttonPadding = 10;
    int menuX = screenWidth - menuWidth - 10;
    int menuY = screenHeight - (menuHeight + buttonPadding) * 4 - 10;
    string[] menuOptions = ["Area 1", "Area 2", "School", "Home"];

    // Load textures for animation
    Texture2D[] arrowTextures = new Texture2D[15];
    for (int i = 0; i < 15; i++) {
        arrowTextures[i] = LoadTexture(toStringz("res/MC*-" ~ (i + 1).to!string() ~ ".png"));
    }
    
    Texture2D mapTexture = LoadTexture("res/map_back.png");
    Music musicMenu;

    if (isAudioEnabled()) {
        musicMenu = LoadMusicStream("res/map_music.mp3");
        PlayMusicStream(musicMenu);
    }
    
    int posY = GetScreenHeight() - 20 - 40;
    int currentFrame = 0;
    float animationSpeed = 0.09f; // Adjust this value to change the speed of the animation
    float timeElapsed = 0.0f;

    // Main game loop
    while (!WindowShouldClose()) {
        UpdateMusicStream(musicMenu);
        
        // Update animation frame
        timeElapsed += GetFrameTime();
        if (timeElapsed >= animationSpeed) {
            currentFrame = (currentFrame + 1) % cast(int)arrowTextures.length;
            timeElapsed -= animationSpeed; // Subtract the animation speed to allow for continuous updates
        }

        if (IsGamepadAvailable(0)) {
            int buttonSize = 30;
            int circleCenterX = 40 + buttonSize / 2;
            int circleCenterY = posY + buttonSize / 2;
            int textYOffset = 7; // Adjust this offset based on your font and text size
            DrawCircle(circleCenterX, circleCenterY, buttonSize / 2, Colors.RED);
            DrawText(("B"), circleCenterX - 5, circleCenterY - textYOffset, 20, Colors.BLACK);
            DrawText((" go to location"), 40 + buttonSize + 5, posY, 20, Colors.BLACK);
        } else {
            int fontSize = 20;
            DrawText(("Press enter to go to location"), 40, posY, fontSize, Colors.BLACK);
        }
        
        if (IsKeyPressed(KeyboardKey.KEY_DOWN) || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN)) {
            selectedMenuIndex = cast(int)((selectedMenuIndex + 1) % menuOptions.length);
        }
        if (IsKeyPressed(KeyboardKey.KEY_UP) || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP)) {
            selectedMenuIndex = cast(int)((selectedMenuIndex - 1 + menuOptions.length) % menuOptions.length);
        }

        // Update rectangle position based on selected menu index
        switch (selectedMenuIndex) {
            case 0:
                rectX = (screenWidth - screenHeight) / 2;
                rectY = screenWidth / 8;
                break;
            case 1:
                rectX = screenHeight - rectWidth - screenHeight / 4 + screenWidth / 3;
                rectY = screenWidth / 5 + screenHeight / 25;
                break;
            case 2:
                rectX = screenHeight - rectWidth - screenHeight / 4 + screenWidth / 3;
                rectY = screenWidth / 4 + screenHeight / 4;
                break;
            case 3:
                rectX = screenHeight / 7;
                rectY = screenWidth / 8;
                break;
            default:
                break;
        }

        if (IsKeyPressed(KeyboardKey.KEY_ENTER) || IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT)) {
            switch (selectedMenuIndex) {
                case 0:
                    loadLocation("res/area1.glb", "res/test.png");
                    location_name = "area1";
                    break;
                case 1:
                    loadLocation("res/area2.glb", "res/test.png");
                    location_name = "area2";
                    break;
                case 2:
                    loadLocation("res/school.glb", "res/test.png");
                    location_name = "schl";
                    break;
                case 3:
                    loadLocation("res/home.glb", "res/test.png");
                    location_name = "home";
                    break;
                default:
                    break;
            }
            break;
        }

        BeginDrawing();
        ClearBackground(Colors.RAYWHITE);
        DrawTexturePro(
            mapTexture,
            Rectangle(0, 0, cast(float)mapTexture.width, cast(float)mapTexture.height),
            Rectangle(0, 0, cast(float)screenWidth, cast(float)screenHeight),
            Vector2(0, 0),
            0.0,
            Colors.WHITE
        );

        for (int i = 0; i < menuOptions.length; i++) {
            Color buttonColor = (i == selectedMenuIndex) ? Colors.DARKGRAY : Colors.LIGHTGRAY;
            DrawRectangleRounded(Rectangle(menuX, menuY + (menuHeight + buttonPadding) * i, menuWidth, menuHeight),
                0.2f, 10, buttonColor);
            DrawText(cast(char*)menuOptions[i], menuX + 10, menuY + 10 + (menuHeight + buttonPadding) * i, 20,
                Colors.WHITE);
        }

        float scaleFactor = 0.7f; // Scale factor
        DrawTexturePro(
            arrowTextures[currentFrame], // Use the current frame for animation
            Rectangle(0, 0, cast(float)arrowTextures[currentFrame].width, cast(float)arrowTextures[currentFrame].height),
            Rectangle(rectX, rectY, rectWidth * scaleFactor, rectHeight * scaleFactor), // Scale the width and height
            Vector2(0, 0),
            0.0,
            Colors.WHITE
        );
        EndDrawing();
    }

    // Unload textures
    for (int i = 0; i < arrowTextures.length; i++) {
        UnloadTexture(arrowTextures[i]);
    }
    UnloadTexture(mapTexture);
    if (isAudioEnabled()) {
        UnloadMusicStream(musicMenu);
    }
    PlayMusicStream(music);
}
