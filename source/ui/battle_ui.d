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

void drawEnemyCubes() {
    foreach (enemyCube; enemyCubes) {
        // Draw the enemy model at the given position
        DrawModel(enemyCube.model, enemyCube.position, 3.6f, Colors.WHITE);
    }
}

void drawHPAboveCubes(Camera3D camera) {
    foreach (index, enemyCube; enemyCubes) {
        Vector3 cubeWorldPosition = enemyCube.position;
        cubeWorldPosition.y += 2.5f;
        Vector2 cubeScreenPosition = GetWorldToScreen(cubeWorldPosition, camera);
        string hpText = "HP: " ~ to!string(enemyCubes[index].health);
        DrawText(toStringz(enemyCube.name), cast(int)cubeScreenPosition.x, cast(int)cubeScreenPosition.y + 30, 20, Colors.RED);
        DrawText(hpText.ptr, cast(int)cubeScreenPosition.x, cast(int)cubeScreenPosition.y, 20, Colors.RED);
    }
}

void attackTab(int element) {
    if (battleState.playerTurn && battleState.playerTurns > 0) {
        switch (element) {
            case 0:
                physicalAttack();
                break;
            case 1:
                // Add other attack types here
                break;
            default:
                break;
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
    int barWidth = 200;
    int barHeight = 20;
    int barX = 10;
    int barY = screenHeight - barHeight - 10;
    float healthPercentage = cast(float)playerHealth / maxPlayerHealth;
    DrawRectangle(barX, barY, barWidth, barHeight, Colors.GRAY);
    DrawRectangle(barX, barY, cast(int)(barWidth * healthPercentage), barHeight, Colors.RED);
    string healthText = "Health: " ~ to!string(playerHealth) ~ "/" ~ to!string(maxPlayerHealth);
    DrawText(healthText.ptr, barX + 5, barY + 5, 10, Colors.WHITE);
}

void physicalAttack() {
    if (enemyCubes.length > selectedEnemyIndex) {
        EnemyCube enemy = enemyCubes[selectedEnemyIndex];
        enemy.health -= 10;
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
    DrawText("GAME OVER", GetScreenWidth() / 2 - MeasureText("GAME OVER", 20) / 2, GetScreenHeight() / 2 - 10, 40, Colors.RED);
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
        UnloadMusicStream(music);
        allowControl = true;
        music = LoadMusicStream(musicpath);
        PlayMusicStream(music);
    }
}

Model enemyModel; // Define at a broader scope to make accessible elsewhere

void initBattle(ref Camera3D camera, ref Vector3 cubePosition, ref float cameraAngle, int randomCounter) {
    if (isAudioEnabled()) {
        StopMusicStream(music);
        music = LoadMusicStream("res/battle.mp3");
        PlayMusicStream(music);
    } else {
        StopMusicStream(music);
    }

    cubePosition.y += 10.0f;
    camera.position.y += 10.0f;
    camera.target.y += 10.0f;
    
    enemyModel = LoadModel("res/enemy_model.glb"); // Load model once here

    Vector3 enemyCubeOffset = Vector3(0.0f, 0.0f, -7.0f);
    for (int i = 0; i <= randomCounter; i++) {
        enemyCubeOffset.x = i * 4.0f;
        Vector3 enemyCubePosition = Vector3Add(cubePosition, enemyCubeOffset);
        EnemyCube enemyCube = {enemyCubePosition, "TestCube" ~ (i + 1).to!string(), 20, enemyModel};
        enemyCubes ~= enemyCube;
        addCube(enemyCube.position, enemyCube.name, ["test"], 0, 0);
    }
    battleState.playerTurns = 1;
    battleState.enemyTurns = cast(int)enemyCubes.length;
    battleState.playerTurn = true;
}

void enemyTurn() {
    if (!battleState.playerTurn) {
        foreach (index, enemyCube; enemyCubes) {
            if (enemyCube.health > 0) {
                playerHealth -= 10;
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

    if (IsKeyPressed(KeyboardKey.KEY_RIGHT) && !selectingEnemy  || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT) && !selectingEnemy) {
        selectedTabIndex = (selectedTabIndex + 1) % numberOfTabs;
        selectedButtonIndex = 0;
    }
    if (IsKeyPressed(KeyboardKey.KEY_LEFT) && !selectingEnemy || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT) && !selectingEnemy) {
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

    if (IsKeyPressed(KeyboardKey.KEY_DOWN)&& !selectingEnemy || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN) && !selectingEnemy) {
        selectedButtonIndex = (selectedButtonIndex + 1) % numberOfButtons;
    }
    if (IsKeyPressed(KeyboardKey.KEY_UP)&& !selectingEnemy || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP) && !selectingEnemy) {
        selectedButtonIndex = (selectedButtonIndex - 1 + numberOfButtons) % numberOfButtons;
    }

    if (IsKeyPressed(KeyboardKey.KEY_ENTER) || IsKeyPressed(KeyboardKey.KEY_SPACE) || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) {
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
            if (enemyCubes[index].health > 0) {
                Vector3 cubeWorldPosition = enemyCube.position;
                cubeWorldPosition.y += 2.5f;
                Vector2 cubeScreenPosition = GetWorldToScreen(cubeWorldPosition, camera);
                Color enemyColor = (index == selectedEnemyIndex) ? Colors.RED : Colors.WHITE;
                DrawCube(enemyCube.position, 2.0f, 2.0f, 2.0f, enemyColor);
                string hpText = "HP: " ~ to!string(enemyCubes[index].health);
                DrawText(cast(char*)enemyCube.name, cast(int)cubeScreenPosition.x, cast(int)cubeScreenPosition.y + 30, 20, enemyColor);
                DrawText(cast(char*)hpText.ptr, cast(int)cubeScreenPosition.x, cast(int)cubeScreenPosition.y, 20, enemyColor);
            }
        }
        if (IsKeyPressed(KeyboardKey.KEY_RIGHT) && selectingEnemy || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT) && selectingEnemy) {
            selectedEnemyIndex = cast(int)((selectedEnemyIndex + 1) % enemyCubes.length);
        }
        if (IsKeyPressed(KeyboardKey.KEY_LEFT)&& selectingEnemy || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT) && selectingEnemy) {
            selectedEnemyIndex = cast(int)((selectedEnemyIndex - 1 + enemyCubes.length) % enemyCubes.length);
        }
    }

    if (!battleState.playerTurn) {
        enemyTurn();
    }

    drawPlayerHealthBar(playerHealth, 120);
    checkForVictory(camera, cubePosition);
}

nothrow void removeCube(string name) {
    // Find the index of the cube in the array by name
    int indexToRemove = -1;
    foreach (index, cube; cubes) {
        if (cube.name == name) {
            indexToRemove = cast(int)index;
            break;
        }
    }

    // If the cube is found, remove it from the array
    if (indexToRemove != -1) {
        cubes = cubes[0 .. indexToRemove] ~ cubes[indexToRemove + 1 .. $];
    }
}
