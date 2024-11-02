module graphics.map;

import raylib;
import graphics.scene;
import std.stdio;
import std.string;
import graphics.main_loop;
import script;
import variables;
import std.conv;
import std.algorithm;
import std.uni: isWhite;

void openMap(string location) {
    const int screenWidth = GetScreenWidth();
    const int screenHeight = GetScreenHeight();
    const int rectWidth = 100;
    const int rectHeight = 100;
    int selectedMenuIndex = 0;
    int rectX, rectY;

    // Define menu options and their corresponding positions
    string[] menuOptions = ["Area 1", "Area 2", "School", "Home"];

    string[] locationNames = ["area1", "area2", "schl", "home"];
    int[][] menuPositions = [
        [(screenWidth - screenHeight) / 2, screenWidth / 8], // Area 1
        [screenHeight - rectWidth - screenHeight / 4 + screenWidth / 3, screenWidth / 5 + screenHeight / 25], // Area 2
        [screenHeight - rectWidth - screenHeight / 4 + screenWidth / 3, screenWidth / 4 + screenHeight / 4], // School
        [screenHeight / 7, screenWidth / 8] // Home
    ];

    // Set initial rectangle position based on location
    switch (location) {
        case "area1": selectedMenuIndex = 0; break;
        case "area2": selectedMenuIndex = 1; break;
        case "schl": selectedMenuIndex = 2; break;
        case "home": selectedMenuIndex = 3; break;
        default: break;
    }
    rectX = menuPositions[selectedMenuIndex][0];
    rectY = menuPositions[selectedMenuIndex][1];
    uint image_size;
    char *image_data = get_file_data_from_archive("res/data.bin", "map_back.png", &image_size);
    SetTargetFPS(60);
    const int menuWidth = screenWidth / 5;
    const int menuHeight = screenHeight / 10;
    const int buttonPadding = 10;
    const int menuX = screenWidth - menuWidth - 10;
    const int menuY = screenHeight - (menuHeight + buttonPadding) * 4 - 10;

    // Load textures for animation
    Texture2D[] arrowTextures = new Texture2D[16];
    foreach (i; 0 .. 16) {
        uint arrowSize;
        char *arrow_data = get_file_data_from_archive("res/data.bin", toStringz("MC*-" ~ i.to!string() ~ ".png"), &arrowSize);
        Image arrowArrow = LoadImageFromMemory(".PNG", cast(const(ubyte)*)arrow_data, arrowSize);
        arrowTextures[i] = LoadTextureFromImage(arrowArrow);
        UnloadImage(arrowArrow);
    }
    Image imageMapBack = LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size);
    Texture2D mapTexture = LoadTextureFromImage(imageMapBack);
    UnloadImage(imageMapBack);
    uint audio_size;
    char *audio_data = get_file_data_from_archive("res/data.bin", "map_music.mp3", &audio_size);
    Music musicMenu;

    if (isAudioEnabled()) {
        musicMenu = LoadMusicStreamFromMemory(".MP3", cast(const(ubyte)*)audio_data, audio_size);
        PlayMusicStream(musicMenu);
    }
    
    int posY = GetScreenHeight() - 20 - 40;
    int currentFrame = 0;
    float animationSpeed = 0.07f;
    float timeElapsed = 0.0f;

    // Main game loop
    while (!WindowShouldClose()) {
        UpdateMusicStream(musicMenu);
        
        // Update animation frame
        timeElapsed += GetFrameTime();
        if (timeElapsed >= animationSpeed) {
            currentFrame = cast(int)((currentFrame + 1) % arrowTextures.length);
            timeElapsed = 0.0f;
        }

        // Handle input
        if (IsGamepadAvailable(0)) {
            DrawCircle(40 + 15, posY + 15, 15, Colors.RED);
            DrawText("B", 40 + 15 - 5, posY + 15 - 7, 20, Colors.BLACK);
            DrawText(" go to location", 40 + 30 + 5, posY, 20, Colors.BLACK);
        } else {
            DrawText("Press enter to go to location", 40, posY, 20, Colors.BLACK);
        }

        if (IsKeyPressed(KeyboardKey.KEY_DOWN) || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN)) {
                        selectedMenuIndex = cast(int)((selectedMenuIndex + 1) % menuOptions.length);
        }
        if (IsKeyPressed(KeyboardKey.KEY_UP) || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP)) {
            selectedMenuIndex = cast(int)((selectedMenuIndex - 1 + menuOptions.length) % menuOptions.length);
        }

        // Update rectangle position based on selected menu index
        rectX = menuPositions[selectedMenuIndex][0];
        rectY = menuPositions[selectedMenuIndex][1];

        if (IsKeyPressed(KeyboardKey.KEY_ENTER) || IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT)) {
            string location_name = locationNames[selectedMenuIndex]; // Convert to lowercase and remove whitespace for location name
            if (!rel) { writeln("Going to " ~ location_name); }
            loadLocation(cast(char*)toStringz("res/" ~ location_name ~ ".glb"));
            isNewLocationNeeded = true;
            break; // Exit the loop after loading the location
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

        // Draw menu options
        for (int i = 0; i < menuOptions.length; i++) {
            Color buttonColor = (i == selectedMenuIndex) ? Colors.DARKGRAY : Colors.LIGHTGRAY;
            DrawRectangleRounded(Rectangle(menuX, menuY + (menuHeight + buttonPadding) * i, menuWidth, menuHeight), 0.2f, 10, buttonColor);
            DrawText(cast(char*)menuOptions[i], menuX + 10, menuY + 10 + (menuHeight + buttonPadding) * i, 20, Colors.WHITE);
        }

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
        EndDrawing();
    }

    // Unload textures and music
    foreach (texture; arrowTextures) {
        UnloadTexture(texture);
    }
    UnloadTexture(mapTexture);
    if (isAudioEnabled()) {
        UnloadMusicStream(musicMenu);
    }
    PlayMusicStream(music); // Play the main music again if needed
}
