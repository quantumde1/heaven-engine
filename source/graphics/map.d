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

    // Set initial rectangle position based on location
    switch (location) {
        case "area1": selectedMenuIndex = 0; break;
        case "area2": selectedMenuIndex = 1; break;
        case "schl": selectedMenuIndex = 2; break;
        case "home": selectedMenuIndex = 3; break;
        default: break;
    }
    rectX = 50; // Fixed position for the arrow
    rectY = 50 + selectedMenuIndex * (rectHeight + 10); // Adjusted for spacing

    // Load font from file

    // Load textures and music
    uint image_size;
    char *image_data = get_file_data_from_archive("res/data.bin", "map_back.png", &image_size);
    Texture2D mapTexture = LoadTextureFromImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size));
    UnloadImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size));

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
    
    int[][] menuPositions = [
        [(screenWidth - screenHeight) / 2, screenWidth / 8], // Area 1
        [screenHeight - rectWidth - screenHeight / 4 + screenWidth / 3, screenWidth / 5 + screenHeight / 25], // Area 2
        [screenHeight - rectWidth - screenHeight / 4 + screenWidth / 3, screenWidth / 4 + screenHeight / 4], // School
        [screenHeight / 7, screenWidth / 8] // Home
    ];

// Initialize Camera2D
Camera2D camera;
camera.target = Vector2(screenWidth / 2.0f, screenHeight / 2.0f);
camera.offset = Vector2(screenWidth / 2.0f, screenHeight / 2.0f);
camera.rotation = 0.0f;
camera.zoom = 1.0f; // Default zoom level
    rectX = menuPositions[selectedMenuIndex][0];
    rectY = menuPositions[selectedMenuIndex][1];
    Color semiTransparentBlack = Color(0, 0, 0, 210); // RGBA: Black with 210 alpha
    float animationSpeed = 0.07f;
    float timeElapsed = 0.0f;
    int posY = GetScreenHeight() - 20 - 40;
    camera.zoom = 1.0f;
    // Fade-in effect
    float fadeAlpha = 255.0f; // Start fully opaque
    while (fadeAlpha > 0) {
        fadeAlpha -= 5; // Decrease alpha
        if (fadeAlpha < 0) fadeAlpha = 0;

        BeginDrawing();
        ClearBackground(Colors.RAYWHITE);
        
        // Draw the map texture
        DrawTexturePro(mapTexture, Rectangle(0, 0, cast(float)mapTexture.width, cast(float)mapTexture.height), Rectangle(0, 0, cast(float)screenWidth, cast(float)screenHeight), Vector2(0, 0), 0.0, Colors.WHITE);
        
        // Draw the interface elements (e.g., menu options)
        DrawRectangle(0, 0, screenWidth, 50, Color(100, 54, 65, 255));
        DrawTextEx(fontdialog, "Select destination", Vector2(20, 10), 30, 0, Colors.WHITE);
        
        for (int i = 0; i < menuOptions.length; i++) {
            Color buttonColor = (i == selectedMenuIndex) ? semiTransparentBlack : Color(0, 0, 0, 150);
            DrawRectangleRounded(Rectangle(10, 60 + (30 * i), 200, 30), 0.03f, 16, buttonColor);
            DrawTextEx(fontdialog, toStringz(menuOptions[i]), Vector2(20, 64 + (30 * i)), 20, 1.0f, Colors.WHITE);
        }
        DrawRectangleRoundedLines(Rectangle(10, 60, 200, 30 * menuOptions.length), 0.03f, 16, 3.0f, Color(100, 54, 65, 255)); // Red color

        // Draw fade rectangle
        DrawRectangle(0, 0, screenWidth, screenHeight, Color(0, 0, 0, cast(ubyte)fadeAlpha)); // Draw fade rectangle
        EndDrawing();
    }

float currentZoom = 1.0f; // Variable to control zoom level
bool needzoom1;
bool needzoom2;

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

    // Update the camera's zoom level
    camera.zoom = currentZoom;
    // Update rectangle position based on selected menu index
        rectX = menuPositions[selectedMenuIndex][0];
        rectY = menuPositions[selectedMenuIndex][1];
        
        if (IsKeyPressed(KeyboardKey.KEY_ENTER) || IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT)) {
            
            string location_name = locationNames[selectedMenuIndex]; // Convert to lowercase and remove whitespace for location name
            if (!rel) { writeln("Going to " ~ location_name); }
            float fadeOutAlpha = 0.0f; // Start fully transparent
            while (fadeOutAlpha < 255) {
                
                fadeOutAlpha += 5; // Increase alpha
                if (fadeOutAlpha > 255) fadeOutAlpha = 255;

                BeginDrawing();
                ClearBackground(Colors.RAYWHITE);
                
                // Draw the map texture
                DrawTexturePro(mapTexture, Rectangle(0, 0, cast(float)mapTexture.width, cast(float)mapTexture.height), Rectangle(0, 0, cast(float)screenWidth, cast(float)screenHeight), Vector2(0, 0), 0.0, Colors.WHITE);
                
                // Draw the interface elements (e.g., menu options)
                DrawRectangle(0, 0, screenWidth, 50, Color(100, 54, 65, 255));
                DrawTextEx(fontdialog, "Select destination", Vector2(20, 10), 30, 0, Colors.WHITE);
                
                for (int i = 0; i < menuOptions.length; i++) {
                    Color buttonColor = (i == selectedMenuIndex) ? semiTransparentBlack : Color(0, 0, 0, 150);
                    DrawRectangleRounded(Rectangle(10, 60 + (30 * i), 200, 30), 0.03f, 16, buttonColor);
                    DrawTextEx(fontdialog, toStringz(menuOptions[i]), Vector2(20, 64 + (30 * i)), 20, 1.0f, Colors.WHITE);
                }
                DrawRectangleRoundedLines(Rectangle(10, 60, 200, 30 * menuOptions.length), 0.03f, 16, 3.0f, Color(100, 54, 65, 255)); // Red color
                
                // Draw fade rectangle
                DrawRectangle(0, 0, screenWidth, screenHeight, Color(0, 0, 0, cast(ubyte)fadeOutAlpha)); // Draw fade rectangle
                EndDrawing();
            }
            loadLocation(cast(char*)toStringz("res/" ~ location_name ~ ".glb"), 19.0f);
            isNewLocationNeeded = true;
            break; // Exit the loop after loading the location
        }

        // Begin drawing with the camera
        BeginMode2D(camera);
        
        // Clear the background
        ClearBackground(Colors.RAYWHITE);
        
        // Draw the map texture
        DrawTexturePro(mapTexture, Rectangle(0, 0, cast(float)mapTexture.width, cast(float)mapTexture.height), Rectangle(0, 0, cast(float)screenWidth, cast(float)screenHeight), Vector2(0, 0), 0.0, Colors.WHITE);
        
        // Draw gray panel
        DrawRectangle(0, 0, screenWidth, 50, Color(100, 54, 65, 255));

        // Draw the "Select destination" text on the gray panel
        DrawTextEx(fontdialog, "Select destination", Vector2(20, 10), 30, 0, Colors.WHITE);

        // Draw allowed locations
        for (int i = 0; i < menuOptions.length; i++) {
            Color buttonColor = (i == selectedMenuIndex) ? semiTransparentBlack : Color(0, 0, 0, 150);
            DrawRectangleRounded(Rectangle(10, 60 + (30 * i), 200, 30), 0.03f, 16, buttonColor);
            DrawTextEx(fontdialog, toStringz(menuOptions[i]), Vector2(20, 64 + (30 * i)), 20, 1.0f, Colors.WHITE);
        }

        // Draw outline for the entire button area
        DrawRectangleRoundedLines(Rectangle(10, 60, 200, 30 * menuOptions.length), 0.03f, 16, 3.0f, Color(100, 54, 65, 255)); // Red color

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

        // End drawing with the camera
        EndMode2D();
        EndDrawing();
    }

    // Unload resources
    UnloadTexture(mapTexture);
    if (audioEnabled) {
        UnloadMusicStream(musicMenu);
    }
    foreach (texture; arrowTextures) {
        UnloadTexture(texture);
    }
}