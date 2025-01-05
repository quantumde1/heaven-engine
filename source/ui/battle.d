// quantumde1 developed software, licensed under BSD-0-Clause license.
module ui.battle;

import raylib;
import std.math;
import variables;
import std.stdio;
import graphics.cubes;
import std.conv;
import std.algorithm;
import scripts.config;
import std.string;
import std.random;
import dialogs.dialog_system;
import std.array;

const float CUBE_DRAW_HEIGHT = 2.5f;
const float PLAYER_HEALTH_BAR_WIDTH = 200.0f;
const float PLAYER_HEALTH_BAR_HEIGHT = 20.0f;
const int PLAYER_HEALTH_BAR_X = 10;
const int PLAYER_HEALTH_BAR_Y_OFFSET = 10;
const int ATTACK_DAMAGE = 10;

void drawPlayerHealthBar(int playerHealth, int maxPlayerHealth) {
    int screenHeight = GetScreenHeight();
    float healthPercentage = cast(float)playerHealth / maxPlayerHealth;
    DrawRectangle(PLAYER_HEALTH_BAR_X, cast(int)(screenHeight - PLAYER_HEALTH_BAR_HEIGHT - PLAYER_HEALTH_BAR_Y_OFFSET), 
                  cast(int)PLAYER_HEALTH_BAR_WIDTH, cast(int)PLAYER_HEALTH_BAR_HEIGHT, Colors.GRAY);
    DrawRectangle(PLAYER_HEALTH_BAR_X, cast(int)(screenHeight - PLAYER_HEALTH_BAR_HEIGHT - PLAYER_HEALTH_BAR_Y_OFFSET), 
                  cast(int)(PLAYER_HEALTH_BAR_WIDTH * healthPercentage), cast(int)PLAYER_HEALTH_BAR_HEIGHT, Colors.RED);
    string healthText = "Health: " ~ to!string(playerHealth) ~ "/" ~ to!string(maxPlayerHealth);
    DrawText(toStringz(healthText), PLAYER_HEALTH_BAR_X + 5, cast(int)(screenHeight - PLAYER_HEALTH_BAR_HEIGHT - 
                  PLAYER_HEALTH_BAR_Y_OFFSET + 5), 10, Colors.WHITE);
}

void drawPlayerManaBar(int playerMana, int maxPlayerMana) {
    int screenHeight = GetScreenHeight();
    float manaPercentage = cast(float)playerMana / maxPlayerMana;
    DrawRectangle(PLAYER_HEALTH_BAR_X, cast(int)(screenHeight - PLAYER_HEALTH_BAR_HEIGHT - 
                  PLAYER_HEALTH_BAR_Y_OFFSET - PLAYER_HEALTH_BAR_HEIGHT - 5), cast(int)PLAYER_HEALTH_BAR_WIDTH, 
                  cast(int)PLAYER_HEALTH_BAR_HEIGHT, Colors.GRAY);
    DrawRectangle(PLAYER_HEALTH_BAR_X, cast(int)(screenHeight - PLAYER_HEALTH_BAR_HEIGHT - 
                  PLAYER_HEALTH_BAR_Y_OFFSET - PLAYER_HEALTH_BAR_HEIGHT - 5), cast(int)(PLAYER_HEALTH_BAR_WIDTH * manaPercentage), 
                  cast(int)PLAYER_HEALTH_BAR_HEIGHT, Colors.BLUE);
    string manaText = "Mana: " ~ to!string(playerMana) ~ "/" ~ to!string(maxPlayerMana);
    DrawText(toStringz(manaText), PLAYER_HEALTH_BAR_X + 5, cast(int)(screenHeight - PLAYER_HEALTH_BAR_HEIGHT - 
                  PLAYER_HEALTH_BAR_Y_OFFSET - PLAYER_HEALTH_BAR_HEIGHT - 5 + 5), 10, Colors.WHITE);
}

void loadAssets() {
    // Populating massive
    for (int i = 0; i <= randomNumber; i++) {
        enemies[i].texture = LoadTexture("res/tex/enemy_poltergheist.png");
        enemies[i].maxHealth = 30;
        enemies[i].currentHealth = enemies[i].maxHealth;
    }
    background = LoadTexture("res/backgrounds/battle.png");
}

void performPhysicalAttack(int enemyIndex) {
    if (enemyIndex >= 0 && enemyIndex < enemies.length) {
        enemies[enemyIndex].currentHealth -= ATTACK_DAMAGE;
        if (enemies[enemyIndex].currentHealth <= 0) {
            enemies[enemyIndex].currentHealth = 0;
            removeEnemy(enemyIndex);
            if (selectedEnemyIndex == enemyIndex) {
                if (enemies.length > 0) {
                    selectedEnemyIndex = (selectedEnemyIndex + 1) % enemies.length;
                } else {
                    selectedEnemyIndex = -1;
                }
            }
        }
    }
}

void initBattle() {
    // Setting states
    loadAssets(); // Загружаем ассеты единожды
    battleState.playerTurns = 1;
    battleState.playerTurn = true;
    drawEnemies();
}

float enemyVerticalOffset = 0.0f; 
float enemySpeed = 3.0f;
float enemyAmplitude = 25.0f;

float blinkTime = 0.0f; // Переменная для отслеживания времени мигания
const float BLINK_SPEED = 8.0f; // Скорость мигания

void drawEnemies() {
    int numberOfEnemies = randomNumber + 1;
    float spacing = 300.0f;
    float startX = (GetScreenWidth() - (numberOfEnemies * spacing)) / 2;

    // Отрисовка фона
    DrawTexturePro(background, Rectangle(0, 0, cast(float)background.width, cast(float)background.height), 
                    Rectangle(0, 0, cast(float)GetScreenWidth(), cast(float)GetScreenHeight()), 
                    Vector2(0, 0), 0.0, Colors.WHITE);
    
    // Обновление вертикального смещения для врагов
    enemyVerticalOffset += enemySpeed;
    if (enemyVerticalOffset > enemyAmplitude || enemyVerticalOffset < -enemyAmplitude) {
        enemySpeed = -enemySpeed;
    }

    blinkTime += GetFrameTime() * BLINK_SPEED;

    for (int i = 0; i < numberOfEnemies; i++) {
        if (enemies[i].currentHealth > 0) { // Проверяем, жив ли враг
            float posX = startX + (i * spacing);
            float posY = (GetScreenHeight() / 2) + enemyVerticalOffset;

            Color enemyColor = Colors.WHITE;
            if (i == selectedEnemyIndex && selectingEnemy) {
                float alpha = (sin(blinkTime) + 1) / 2;
                enemyColor = Color(cast(ubyte)255, cast(ubyte)255, cast(ubyte)0, cast(ubyte)cast(int)(alpha * 255));
            }

            DrawTextureEx(enemies[i].texture, Vector2(posX, -100 + posY), 0, 5.0, enemyColor);
        }
    }
}

void removeAll() {
    // Iterate through each enemy cube and set its health to zero
    foreach (index, enemy; enemies) {
        enemies[index].currentHealth = 0; // Set health to zero to trigger removal logic
    }
    
    // Convert the fixed-size array to a dynamic array and filter out enemies with health greater than 0
    enemies = enemies.array().filter!(enemy => enemy.currentHealth > 0).array(); // Convert FilterResult to array
}

/*void removeEnemy(int enemyIndex) {
    if (enemyIndex >= 0 && enemyIndex < enemies.length) {
        // Remove the enemy by shifting elements to the left
        for (int i = enemyIndex; i < enemies.length - 1; i++) {
            enemies[i] = enemies[i + 1];
        }
    }
}*/

void removeEnemy(int enemyIndex) {
    if (enemyIndex >= 0 && enemyIndex < enemies.length) {
        enemies[enemyIndex].currentHealth = 0; // Устанавливаем здоровье врага в ноль
    }
}

void enemyTurn() {
    playerHealth -= ATTACK_DAMAGE;
}

bool areAllEnemiesDefeated() {
    foreach (enemy; enemies) {
        if (enemy.currentHealth > 0) {
            return false; // At least one enemy is still alive
        }
    }
    return true; // All enemies are defeated
}

void drawBattleMenu() {
    drawEnemies();
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    int barHeight = screenHeight / 9;
    string[] menuTabs = ["Attack", "Skill", "Item", "Talk", "Escape"];
    Color semiTransparentBlack = Color(0, 0, 0, 200); // RGBA: Black with 210 alpha
    int numberOfTabs = cast(int)menuTabs.length;
    int tabWidth = screenWidth / numberOfTabs;
    DrawRectangleRounded(Rectangle(0, 0, screenWidth, barHeight), 0.03f, 16, semiTransparentBlack);
    // Draw the outline for the rounded rectangle
    DrawRectangleRoundedLinesEx(Rectangle(0, 0, screenWidth, barHeight), 0.03f, 16, 5.0f, Color(100, 54, 65, 255)); // Red color for the outline
    for (int i = 0; i < numberOfTabs; i++) {
        Color tabColor = (i == selectedTabIndex) ? semiTransparentBlack : Color(0, 0, 0, 150);
        DrawRectangle(i * tabWidth, 0, tabWidth, barHeight, tabColor);
        
        int textY = barHeight - 40;
        DrawTextEx(fontdialog, toStringz(menuTabs[i]), Vector2(i * tabWidth + 10, textY), 40, 1.0f, Colors.WHITE);
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
    int rectY = barHeight + 15;

    int buttonHeight = 50;
    int buttonMargin = 10;
    drawPlayerHealthBar(playerHealth, 120);
    drawPlayerManaBar(playerMana, 30);
    // Draw the background rectangle for the button area
    DrawRectangleRounded(Rectangle(rectX, rectY, rectWidth, rectHeight), 0.03f, 16, semiTransparentBlack);
    
    for (int i = 0; i < numberOfButtons; i++) {
        int buttonY = rectY + (buttonHeight + buttonMargin) * i;
        Color buttonColor = (i == selectedButtonIndex) ? semiTransparentBlack : Color(0, 0, 0, 150);
        Color textColor = (i == selectedButtonIndex) ? Colors.WHITE : Colors.DARKGRAY;
        // Draw the rounded rectangle for each button
        DrawRectangleRounded(Rectangle(rectX + buttonMargin, buttonY, rectWidth - (2 * buttonMargin), buttonHeight), 0.03f, 16, buttonColor);
        
        // Draw the button text
        DrawTextEx(fontdialog, toStringz(buttonText[i]), Vector2(rectX + buttonMargin + 10, buttonY + 4), 30, 1.0f, textColor);
    }
    switch (selectedTabIndex) {
        case 0: // Attack
            if (selectedTabIndex == 0 && IsKeyPressed(KeyboardKey.KEY_ENTER) && !selectingEnemy) {
                debug_writeln("Enter pressed with selecting enemy to true");
                selectingEnemy = true;
                // Дополнительная проверка, чтобы избежать повторного срабатывания
                if (enemies[selectedEnemyIndex].currentHealth <= 0) {
                    debug_writeln("Enemy no.", selectedEnemyIndex, " destroyed!");
                }
            } else if (selectingEnemy && IsKeyPressed(KeyboardKey.KEY_ENTER)) {
                debug_writeln("enter pressed for acting");
                performPhysicalAttack(selectedEnemyIndex);
                debug_writeln("selecting enemy to false");
                for (int i = 0; i <= randomNumber; i++) {
                    debug_writeln("HP of enemy[",i,"] is: ", enemies[i].currentHealth);
                    if (enemies[i].currentHealth >= 0) {
                        debug_writeln("enemy turn!");
                        enemyTurn();
                        selectingEnemy = false;
                    } else {
                        debug_writeln("ignore");
                    }
                }
            }
            break;
        default:
            break;
    }
    if (selectingEnemy) {
        if (IsKeyPressed(KeyboardKey.KEY_LEFT) || (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT))) {
            selectedEnemyIndex -= 1;
            if (selectedEnemyIndex == -1) {
                selectedEnemyIndex = randomNumber;
            }
            debug_writeln("Pressed left, counter: ", selectedEnemyIndex, " and enemy counter at all: ", randomNumber);
        }
        if (IsKeyPressed(KeyboardKey.KEY_RIGHT) || (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT))) {
            if (selectedEnemyIndex == randomNumber) {
                selectedEnemyIndex = 0;
            } else {
                selectedEnemyIndex += 1;
            }
            debug_writeln("Pressed right, counter: ", selectedEnemyIndex, " and enemy counter at all: ", randomNumber);
        }
    }
    // Draw the outline for the button area
    DrawRectangleRoundedLinesEx(Rectangle(rectX, rectY, rectWidth, rectHeight), 0.03f, 16, 5.0f, Color(100, 54, 65, 255)); // Red color
    if ((IsKeyPressed(KeyboardKey.KEY_DOWN) && !selectingEnemy) || 
    (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN) && !selectingEnemy)) {
        selectedButtonIndex = (selectedButtonIndex + 1) % numberOfButtons;
    }
    if ((IsKeyPressed(KeyboardKey.KEY_UP) && !selectingEnemy) || 
    (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP) && !selectingEnemy)) {
        selectedButtonIndex = (selectedButtonIndex - 1 + numberOfButtons) % numberOfButtons;
    }
    if (areAllEnemiesDefeated()) {
        debug_writeln("Exiting from battle");
        for (int i = 0; i <= randomNumber; i++) {
            for (int j = randomNumber; j < enemies.length - 1; j++) {
                enemies[j] = enemies[j + 1];
            }
            UnloadTexture(enemies[i].texture);
        }
        StopMusicStream(music);
        debug_writeln("setting music to ",musicpath);
        uint audio_size;
        char *audio_data = get_file_data_from_archive("res/data.bin", musicpath, &audio_size);
        
        if (audioEnabled) {
            UnloadMusicStream(music);
            music = LoadMusicStreamFromMemory(".mp3", cast(const(ubyte)*)audio_data, audio_size);
        }
        PlayMusicStream(music);
        allowControl = true;
        inBattle = false;
    }
}