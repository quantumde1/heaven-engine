// quantumde1 developed software, licensed under BSD-0-Clause license.
module ui.battle_ui;

import raylib;
import std.math;
import variables;
import std.stdio;
import graphics.cubes;
import std.conv;
import std.algorithm;
import script;
import std.string;
import std.random;

const float CUBE_DRAW_HEIGHT = 2.5f;
const float PLAYER_HEALTH_BAR_WIDTH = 200.0f;
const float PLAYER_HEALTH_BAR_HEIGHT = 20.0f;
const int PLAYER_HEALTH_BAR_X = 10;
const int PLAYER_HEALTH_BAR_Y_OFFSET = 10;
const int ATTACK_DAMAGE = 10;

void drawEnemyCubes() {
    foreach (enemyCube; enemyCubes) {
        DrawModel(enemyCube.model, enemyCube.position, 3.6f, Colors.WHITE);
    }
}

void drawHPAboveCubes(Camera3D camera) {
    foreach (enemyCube; enemyCubes) {
        Vector3 cubeWorldPosition = enemyCube.position;
        cubeWorldPosition.y += CUBE_DRAW_HEIGHT;
        Vector2 cubeScreenPosition = GetWorldToScreen(cubeWorldPosition, camera);
        string hpText = "HP: " ~ to!string(enemyCube.health);
        DrawText(toStringz(enemyCube.name), cast(int)cubeScreenPosition.x, cast(int)cubeScreenPosition.y + 30, 20, 
        Colors.RED);
        DrawText(hpText.ptr, cast(int)cubeScreenPosition.x, cast(int)cubeScreenPosition.y, 20, Colors.RED);
    }
}

void attackTab(int element) {
    if (battleState.playerTurn && battleState.playerTurns > 0) {
        if (element == 0) {
            physicalAttack();
        }
        battleState.playerTurns--;
        if (battleState.playerTurns <= 0) {
            battleState.playerTurn = false;
            battleState.enemyTurns = cast(int)enemyCubes.length;
        }
    }
}

void drawPlayerHealthBar(int playerHealth, int maxPlayerHealth) {
    int screenHeight = GetScreenHeight();
    float healthPercentage = cast(float)playerHealth / maxPlayerHealth;
    DrawRectangle(PLAYER_HEALTH_BAR_X, cast(int)(screenHeight - PLAYER_HEALTH_BAR_HEIGHT - 
    PLAYER_HEALTH_BAR_Y_OFFSET), cast(int)PLAYER_HEALTH_BAR_WIDTH, cast(int)PLAYER_HEALTH_BAR_HEIGHT, Colors.GRAY);
    DrawRectangle(PLAYER_HEALTH_BAR_X, cast(int)(screenHeight - PLAYER_HEALTH_BAR_HEIGHT - 
    PLAYER_HEALTH_BAR_Y_OFFSET), cast(int)(PLAYER_HEALTH_BAR_WIDTH * healthPercentage), 
    cast(int)PLAYER_HEALTH_BAR_HEIGHT, Colors.RED);
    string healthText = "Health: " ~ to!string(playerHealth) ~ "/" ~ to!string(maxPlayerHealth);
    DrawText(toStringz(healthText), PLAYER_HEALTH_BAR_X + 5, cast(int)(screenHeight - PLAYER_HEALTH_BAR_HEIGHT - 
    PLAYER_HEALTH_BAR_Y_OFFSET + 5), 10, Colors.WHITE);
}

void physicalAttack() {
    if (selectedEnemyIndex < enemyCubes.length) {
        EnemyCube enemy = enemyCubes[selectedEnemyIndex];
        enemy.health -= ATTACK_DAMAGE;
        if (!rel) writeln("Attacked ", enemy.name, ", Health left: ", enemy.health);
        if (enemy.health <= 0) {
            if (!rel) writeln(enemy.name, " is destroyed!");
            enemyCubes = enemyCubes[0 .. selectedEnemyIndex] ~ enemyCubes[selectedEnemyIndex + 1 .. $];
            removeCube(enemy.name);
        } else {
            enemyCubes[selectedEnemyIndex] = enemy;
        }
    }
}

void gameOverScreen() {
    DrawText("GAME OVER", GetScreenWidth() / 2 - MeasureText("GAME OVER", 20) / 2, GetScreenHeight() / 2 - 10, 40,
     Colors.RED);
    
}

void checkForVictory(ref Camera3D camera, ref Vector3 cubePosition) {
    if (all(enemyCubes.map!(cube => cube.health <= 0))) {
        if (!rel) {
            writeln("All enemies defeated!");
        }
        inBattle = false;
        cubePosition = originalCubePosition;
        camera.position = originalCameraPosition;
        camera.target = originalCameraTarget;
        StopMusicStream(music);
        UnloadModel(enemyModel);
        allowControl = true;
    }
}

Model enemyModel; // Define at a broader scope to make accessible elsewhere

void initBattle(ref Camera3D camera, ref Vector3 cubePosition, ref float cameraAngle, int randomCounter) {
    if (!isBossfight) {
        uint audio_size;
        char *audio_data = get_file_data_from_archive("res/data.bin", "battle.mp3", &audio_size);
        if (audioEnabled) {
            StopMusicStream(music);
            musicBattle = LoadMusicStreamFromMemory(".mp3", cast(const(ubyte)*)audio_data, audio_size);
            PlayMusicStream(musicBattle);
        } else {
            StopMusicStream(music);
        }
    } else {
        uint audio_size;
        char *audio_data = get_file_data_from_archive("res/data.bin", "boss_battle.mp3", &audio_size);
        if (audioEnabled) {
            StopMusicStream(music);
            musicBattle = LoadMusicStreamFromMemory(".mp3", cast(const(ubyte)*)audio_data, audio_size);
            PlayMusicStream(musicBattle);
        } else {
            StopMusicStream(music);
        }
    }
    cubePosition.y += 10.0f;
    camera.position.y += 10.0f;
    camera.target.y += 10.0f;

    enemyModel = LoadModel("res/enemy_model.glb"); // Load model once here

    Vector3 enemyCubeOffset = Vector3(0.0f, 0.0f, -7.0f);
    for (int i = 0; i <= randomCounter; i++) {
        enemyCubeOffset.x = i * 4.0f;
        Vector3 enemyCubePosition = Vector3Add(cubePosition, enemyCubeOffset);
        EnemyCube enemyCube = {enemyCubePosition, "debug" ~ (i + 1).to!string(), 20, enemyModel};
        enemyCubes ~= enemyCube;
        addCube(enemyCube.position, enemyCube.name, [""], 0, 0);
    }
    battleState.playerTurns = 1;
    battleState.enemyTurns = cast(int)enemyCubes.length;
    battleState.playerTurn = true;
}

void enemyTurn() {
    if (!battleState.playerTurn) {
        foreach (enemyCube; enemyCubes) {
            if (enemyCube.health > 0) {
                playerHealth -= ATTACK_DAMAGE;
                if (!rel) {
                    writeln("Enemy ", enemyCube.name, " attacks! Player HP: ", playerHealth);
                }
                battleState.enemyTurns--;

                if (playerHealth <= 0) {
                    if (!rel) {
                        writeln("Player is defeated!");
                    }
                    gameOverScreen();
                    return;
                }
            }
        }
        if (battleState.enemyTurns <= 0) {
            battleState.playerTurn = true;
            battleState.playerTurns = 1;
        }
    }
}

void drawBattleUI(ref Camera3D camera, ref Vector3 cubePosition) {
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    Color barColor = Colors.BLUE;
    int barHeight = screenHeight / 9;
    DrawRectangle(0, 0, screenWidth, barHeight, barColor);
    string[] menuTabs = ["Attack", "Skill", "Item", "Talk", "Escape"];
    int numberOfTabs = cast(int)menuTabs.length;
    int tabWidth = screenWidth / numberOfTabs;

    for (int i = 0; i < numberOfTabs; i++) {
        Color tabColor = (i == selectedTabIndex) ? Colors.DARKGRAY : Colors.LIGHTGRAY;
        DrawRectangle(i * tabWidth, 0, tabWidth, barHeight, tabColor);
        DrawText(cast(char*)menuTabs[i], i * tabWidth + 10, 10, 20, Colors.WHITE);
    }

    if ((IsKeyPressed(KeyboardKey.KEY_RIGHT) && !selectingEnemy) || (IsGamepadButtonPressed(gamepadInt, 
    GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT) && !selectingEnemy) || (IsGamepadButtonPressed(gamepadInt, 
    GamepadButton.GAMEPAD_BUTTON_RIGHT_TRIGGER_1) && !selectingEnemy)) {
        selectedTabIndex = (selectedTabIndex + 1) % numberOfTabs;
        selectedButtonIndex = 0;
    }
    if ((IsKeyPressed(KeyboardKey.KEY_LEFT) && !selectingEnemy) || (IsGamepadButtonPressed(gamepadInt, 
    GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT) && !selectingEnemy) || (IsGamepadButtonPressed(gamepadInt, 
    GamepadButton.GAMEPAD_BUTTON_LEFT_TRIGGER_1) && !selectingEnemy)) {
        selectedTabIndex = (selectedTabIndex - 1 + numberOfTabs) % numberOfTabs;
        selectedButtonIndex = 0;
    }

    string[] buttonText = buttonTexts[selectedTabIndex];
    int numberOfButtons = cast(int)buttonText.length;
    int rectWidth = screenWidth / 4;
    int rectHeight = (2 * screenHeight) / 3;
    int rectX = 10;
    int rectY = barHeight + 10;
    DrawRectangle(rectX, rectY, rectWidth, rectHeight, Colors.GRAY);
    
    int buttonHeight = 50;
    int buttonMargin = 10;
    for (int i = 0; i < numberOfButtons; i++) {
        int buttonY = rectY + (buttonHeight + buttonMargin) * i;
        Color buttonColor = (i == selectedButtonIndex) ? Colors.GRAY : Colors.LIGHTGRAY;
        DrawRectangle(rectX + buttonMargin, buttonY, rectWidth - (2 * buttonMargin), buttonHeight, buttonColor);
        DrawText(cast(char*)buttonText[i], rectX + buttonMargin + 10, buttonY + 10, 20, Colors.BLACK);
    }
    if (isBossfight) {
        if (IsKeyPressed(KeyboardKey.KEY_ENTER) && selectedButtonIndex == 0 && selectedTabIndex == 4 || 
            IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN) && selectedButtonIndex == 0 && selectedTabIndex == 4) {
            showRunMessage = true; // Set the flag to true when the message should be shown
            runMessageTimer = 0.0f; // Reset the timer
        }

        // Update the timer in the drawBattleUI function
        if (showRunMessage) {
            runMessageTimer += GetFrameTime(); // Increment the timer by the time since the last frame
            if (runMessageTimer >= 3.0f) {
                showRunMessage = false; // Hide the message after 3 seconds
            }
        }

        // Draw the message if the flag is true
        if (showRunMessage) {
            DrawText("You cannot run!", GetScreenWidth() / 2 - MeasureText("You cannot run!", 20) / 2, GetScreenHeight() / 2 - 10, 40, Colors.RED);
        }
    } else {
        if (IsKeyPressed(KeyboardKey.KEY_ENTER) && selectedButtonIndex == 0 && selectedTabIndex == 4 || 
            IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN) && selectedButtonIndex == 0 && selectedTabIndex == 4) {
            
            showRunMessage = true; // Set the flag to true when the message should be shown
            runMessageTimer = 0.0f; // Reset the timer
        }
    }
    if ((IsKeyPressed(KeyboardKey.KEY_DOWN) && !selectingEnemy) || 
    (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN) && !selectingEnemy)) {
        selectedButtonIndex = (selectedButtonIndex + 1) % numberOfButtons;
    }
    if ((IsKeyPressed(KeyboardKey.KEY_UP) && !selectingEnemy) || 
    (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP) && !selectingEnemy)) {
        selectedButtonIndex = (selectedButtonIndex - 1 + numberOfButtons) % numberOfButtons;
    }

    if (IsKeyPressed(KeyboardKey.KEY_ENTER) || IsKeyPressed(KeyboardKey.KEY_SPACE) || 
    IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) {
        if (selectedTabIndex == 0 && !selectingEnemy) {
            secInBattle = true;
            selectingEnemy = true;
        } else if (selectingEnemy) {
            attackTab(selectedButtonIndex);
            selectingEnemy = false;
        }
    }

    // Draw enemy model
    BeginMode3D(camera);
    drawEnemyCubes();
    EndMode3D();

    if (selectingEnemy) {
        foreach (index, enemyCube; enemyCubes) {
            if (enemyCube.health > 0) {
                Vector3 cubeWorldPosition = enemyCube.position;
                cubeWorldPosition.y += CUBE_DRAW_HEIGHT;
                Vector2 cubeScreenPosition = GetWorldToScreen(cubeWorldPosition, camera);
                Color enemyColor = (index == selectedEnemyIndex) ? Colors.RED : Colors.WHITE;
                DrawCube(enemyCube.position, 2.0f, 2.0f, 2.0f, enemyColor);
                string hpText = "HP: " ~ to!string(enemyCube.health);
                DrawText(toStringz(enemyCube.name), cast(int)cubeScreenPosition.x, cast(int)cubeScreenPosition.y + 30,
                20, enemyColor);
                DrawText(cast(char*)(hpText.ptr), cast(int)cubeScreenPosition.x, cast(int)cubeScreenPosition.y, 
                20, enemyColor);
            }
        }
        if ((IsKeyPressed(KeyboardKey.KEY_RIGHT) && selectingEnemy) || (IsGamepadButtonPressed(gamepadInt, 
        GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT) && selectingEnemy)) {
            selectedEnemyIndex = cast(int)((selectedEnemyIndex + 1) % enemyCubes.length);
        }
        if ((IsKeyPressed(KeyboardKey.KEY_LEFT) && selectingEnemy) || (IsGamepadButtonPressed(gamepadInt,
        GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT) && selectingEnemy)) {
            selectedEnemyIndex = cast(int)((selectedEnemyIndex - 1 + enemyCubes.length) % enemyCubes.length);
        }
    }

    if (!battleState.playerTurn) {
        enemyTurn();
    }

    drawPlayerHealthBar(playerHealth, 120);
    checkForVictory(camera, cubePosition);
}