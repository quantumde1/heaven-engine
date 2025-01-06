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
const int ATTACK_DAMAGE = 5;
const int PLAYER_DAMAGE = 15;
// initialization block

void loadAssets() {
    // Populating massive
    for (int i = 0; i <= randomNumber; i++) {
        //now its hardcoded, also setting everything for enemies
        enemies[i].texture = LoadTexture("res/tex/enemy_poltergheist.png");
        enemies[i].maxHealth = 30;
        enemies[i].currentHealth = enemies[i].maxHealth;
    }
    background = LoadTexture("res/backgrounds/battle.png");
}

void initBattle() {
    //Setting states and loading assets
    loadAssets();
    battleState.playerTurns = 1;
    battleState.playerTurn = true;
}

void exitBattle() {
    // Exit the battle if all enemies are defeated
    debug_writeln("Exiting from battle");
    for (int i = 0; i <= randomNumber; i++) {
        for (int j = randomNumber; j < enemies.length - 1; j++) {
            enemies[j] = enemies[j + 1]; // Shift enemies left
        }
        UnloadTexture(enemies[i].texture); // Unload enemy texture
    }
    StopMusicStream(music);
    debug_writeln("Setting music to ", musicpath.to!string);
    
    uint audio_size;
    char *audio_data = get_file_data_from_archive("res/data.bin", musicpath, &audio_size);
    
    if (audioEnabled) {
        UnloadMusicStream(music);
        music = LoadMusicStreamFromMemory(".mp3", cast(const(ubyte)*)audio_data, audio_size);
    }
    PlayMusicStream(music);
    allowControl = true; // Allow player control again
    inBattle = false; // Set battle state to false
}

// end of init

//UI block

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

float blinkTime = 0.0f; // Переменная для отслеживания времени мигания
const float BLINK_SPEED = 8.0f; // Скорость мигания

void drawEnemies() {
    long numberOfEnemies = enemies.length;
    static float enemyVerticalOffset = 0.0f; 
    static float enemySpeed = 3.0f;
    static float enemyAmplitude = 25.0f;
    static float spacing = 300.0f;
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

    for (long i = 0; i < numberOfEnemies; i++) {
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

bool drawBattleUI = true;

void checkVictory() {
    bool allEnemiesDefeated = true; // Assume all enemies are defeated

    // Iterate through the enemies array
    foreach (enemy; enemies) {
        if (enemy.currentHealth > 0) {
            allEnemiesDefeated = false; // Found an enemy that is still alive
            break; // No need to check further
        }
    }

    // If all enemies are defeated, handle victory logic
    if (allEnemiesDefeated) {
        debug_writeln("All enemies have been defeated! Victory!");
        drawBattleUI = false;
    }
}

void drawBattleMenu() {
    checkVictory();
    // Draw enemies on the screen
    drawEnemies();
    Color semiTransparentBlack = Color(0, 0, 0, 200); // Black with 200 alpha
    if (drawBattleUI) {
        // Set up screen dimensions and UI variables
        int screenWidth = GetScreenWidth();
        int screenHeight = GetScreenHeight();
        int barHeight = screenHeight / 9;
        string[] menuTabs = ["Attack", "Skill", "Item", "Talk", "Escape"];
        int numberOfTabs = cast(int)menuTabs.length;
        int tabWidth = screenWidth / numberOfTabs;

        // Prepare button text and dimensions
        string[] buttonText = buttonTexts[selectedTabIndex];
        int numberOfButtons = cast(int)buttonText.length;
        int rectWidth = screenWidth / 4;
        int rectHeight = (2 * screenHeight) / 3;
        int rectX = 10;
        int rectY = barHeight + 15;

        // Button dimensions
        int buttonHeight = 50;
        int buttonMargin = 10;

        // Draw the menu bar
        drawMenuBar(barHeight, tabWidth, menuTabs, semiTransparentBlack);

        // Draw player health and mana bars
        drawPlayerHealthBar(playerHealth, 120);
        drawPlayerManaBar(playerMana, 30);

        // Draw the button panel
        drawButtonPanel(rectX, rectY, rectWidth, rectHeight, buttonText, numberOfButtons, buttonHeight, buttonMargin);

        // Handle input for menu navigation
        handleMenuInput(numberOfButtons, numberOfTabs);
    } else {
        int addXP = 5 * (randomNumber + 1);
        int rectWidth = GetScreenWidth() / 3;
        int rectHeight = GetScreenHeight() / 2;
        int rectX = (GetScreenWidth() - rectWidth) / 2;
        int rectY = (GetScreenHeight() - rectHeight) / 2;

        DrawRectangleRounded(Rectangle(rectX, rectY, rectWidth, rectHeight), 0.03f, 16, semiTransparentBlack);
        DrawRectangleRoundedLinesEx(Rectangle(rectX, rectY, rectWidth, rectHeight), 0.03f, 16, 5.0f, Color(100, 54, 65, 255));
        
        // Начальная позиция Y для текста
        float textY = rectY + 30;

        DrawTextEx(fontdialog, "Results:", Vector2(rectX + 30, textY), 40, 1.0f, Colors.WHITE);
        textY += 50; // Смещение для следующей строки (можно настроить по желанию)

        DrawTextEx(fontdialog, toStringz("Achieved XP: " ~ to!string(addXP)), Vector2(rectX + 30, textY), 30, 1.0f, Colors.WHITE);
        textY += 40; // Смещение для следующей строки

        DrawTextEx(fontdialog, toStringz("Current XP: " ~ to!string(XP+addXP)), Vector2(rectX + 30, textY), 30, 1.0f, Colors.WHITE);

        if (IsKeyPressed(KeyboardKey.KEY_ENTER)) {
            float fadeOutAlpha = 0.0f; // Start fully transparent
            while (fadeOutAlpha < 255) {
                fadeOutAlpha += 5; // Increase alpha
                if (fadeOutAlpha > 255) fadeOutAlpha = 255;
                BeginDrawing();
                // Draw fade rectangle
                DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), Color(0, 0, 0, cast(ubyte)fadeOutAlpha)); // Draw fade rectangle
                EndDrawing();
            }
            debug_writeln("Exiting from battle");
            for (int i = 0; i <= randomNumber; i++) {
                for (int j = randomNumber; j < enemies.length - 1; j++) {
                    enemies[j] = enemies[j + 1];
                }
                UnloadTexture(enemies[i].texture);
            }
            StopMusicStream(music);
            debug_writeln("setting music to ",to!string(musicpath));
            uint audio_size;
            char *audio_data = get_file_data_from_archive("res/data.bin", musicpath, &audio_size);
            
            if (audioEnabled) {
                UnloadMusicStream(music);
                music = LoadMusicStreamFromMemory(".mp3", cast(const(ubyte)*)audio_data, audio_size);
            }
            PlayMusicStream(music);
            XP += addXP;
            inBattle = false;
            allowControl = true;
            drawBattleUI = true;
        }
    }
}

void drawMenuBar(int barHeight, int tabWidth, string[] menuTabs, Color semiTransparentBlack) {
    // Draw the menu bar background
    DrawRectangleRounded(Rectangle(0, 0, GetScreenWidth(), barHeight), 0.03f, 16, semiTransparentBlack);
    DrawRectangleRoundedLinesEx(Rectangle(0, 0, GetScreenWidth(), barHeight), 0.03f, 16, 5.0f, Color(100, 54, 65, 255)); // Red outline

    // Draw each tab in the menu
    for (int i = 0; i < menuTabs.length; i++) {
        Color tabColor = (i == selectedTabIndex) ? semiTransparentBlack : Color(0, 0, 0, 150);
        Color fontColor = (i == selectedTabIndex) ? Colors.WHITE : Colors.DARKGRAY;
        DrawRectangle(i * tabWidth, 0, tabWidth, barHeight, tabColor);
        
        int textY = barHeight - 40;
        DrawTextEx(fontdialog, toStringz(menuTabs[i]), Vector2(i * tabWidth + 10, textY), 40, 1.0f, fontColor);
    }
}

void drawButtonPanel(int rectX, int rectY, int rectWidth, int rectHeight, string[] buttonText, int numberOfButtons, int buttonHeight, int buttonMargin) {
    // Draw the button panel background
    DrawRectangleRounded(Rectangle(rectX, rectY, rectWidth, rectHeight), 0.03f, 16, Color(0, 0, 0, 200));

    // Draw each button
    for (int i = 0; i < numberOfButtons; i++) {
        int buttonY = rectY + (buttonHeight + buttonMargin) * i;
        Color buttonColor = (i == selectedButtonIndex) ? Color(0, 0, 0, 200) : Color(0, 0, 0, 150);
        Color textColor = (i == selectedButtonIndex) ? Colors.WHITE : Colors.DARKGRAY;

        // Draw the rounded rectangle for each button
        DrawRectangleRounded(Rectangle(rectX + buttonMargin, buttonY, rectWidth - (2 * buttonMargin), buttonHeight), 0.03f, 16, buttonColor);
        
        // Draw the button text
        DrawTextEx(fontdialog, toStringz(buttonText[i]), Vector2(rectX + buttonMargin + 10, buttonY + 4), 30, 1.0f, textColor);
    }

    // Draw the button panel outline
    DrawRectangleRoundedLinesEx(Rectangle(rectX, rectY, rectWidth, rectHeight), 0.03f, 16, 5.0f, Color(100, 54, 65, 255)); // Red outline
}

void handleMenuInput(int numberOfButtons, int numberOfTabs) {
    // Handle input for navigating through buttons and tabs
    if ((IsKeyPressed(KeyboardKey.KEY_DOWN) && !selectingEnemy) || 
        (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN) && !selectingEnemy)) {
        selectedButtonIndex = (selectedButtonIndex + 1) % numberOfButtons;
    }
    if ((IsKeyPressed(KeyboardKey.KEY_UP) && !selectingEnemy) || 
        (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP) && !selectingEnemy)) {
        selectedButtonIndex = (selectedButtonIndex - 1 + numberOfButtons) % numberOfButtons;
    }
    if ((IsKeyPressed(KeyboardKey.KEY_RIGHT) && !selectingEnemy) || 
        (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT) && !selectingEnemy) || 
        (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_TRIGGER_1) && !selectingEnemy)) {
        selectedTabIndex = (selectedTabIndex + 1) % numberOfTabs;
        selectedButtonIndex = 0; // Reset button selection when changing tabs
    }
    if ((IsKeyPressed(KeyboardKey.KEY_LEFT) && !selectingEnemy) || 
        (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT) && !selectingEnemy) || 
        (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_TRIGGER_1) && !selectingEnemy)) {
        selectedTabIndex = (selectedTabIndex - 1 + numberOfTabs) % numberOfTabs;
        selectedButtonIndex = 0; // Reset button selection when changing tabs
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
                debug_writeln("current selected enemy(", selectedEnemyIndex ,") hp before attack is ", enemies[selectedEnemyIndex].currentHealth);
                performPhysicalAttack(selectedEnemyIndex);
                debug_writeln("current selected enemy(", selectedEnemyIndex ,") hp after attack is ", enemies[selectedEnemyIndex].currentHealth);
                debug_writeln("selecting enemy to false");
                for (int i = 0; i <= randomNumber; i++) {
                    debug_writeln("HP of enemy[",i,"] is: ", enemies[i].currentHealth);
                    if (enemies[i].currentHealth > 0) {
                        debug_writeln("enemy turn!");
                        enemyTurn();
                        selectingEnemy = false;
                    } else {
                        debug_writeln("ignore");
                        selectingEnemy = false;
                    }
                }
            }
            break;
        default:
            break;
    }
    if (selectingEnemy) {
        if (enemies[selectedEnemyIndex].currentHealth == 0) {
            for (int i = 0; i <= randomNumber; i++) {
                if (enemies[i].currentHealth > 0) {
                    selectedEnemyIndex = i;
                }
            }
        }
        if (IsKeyPressed(KeyboardKey.KEY_LEFT) || (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT))) {
            if (enemies[selectedEnemyIndex].currentHealth <= 0) {
                selectedEnemyIndex = selectedEnemyIndex;
            } else {
                selectedEnemyIndex -= 1;
                if (selectedEnemyIndex == -1) {
                    selectedEnemyIndex = randomNumber;
                }
                debug_writeln("Pressed left, counter: ", selectedEnemyIndex, " and enemy counter at all: ", randomNumber);
            }
        }
        if (IsKeyPressed(KeyboardKey.KEY_RIGHT) || (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT))) {
            if (enemies[selectedEnemyIndex].currentHealth <= 0) {
                selectedEnemyIndex = selectedEnemyIndex;
            } else {
                if (selectedEnemyIndex == randomNumber) {
                    selectedEnemyIndex = 0;
                } else {
                    selectedEnemyIndex += 1;
                }
                debug_writeln("Pressed right, counter: ", selectedEnemyIndex, " and enemy counter at all: ", randomNumber);
            }
        }
    }
}

// end of UI

// battle logic

void performPhysicalAttack(int enemyIndex) {
    if (enemies[enemyIndex].currentHealth > 0) {
        enemies[enemyIndex].currentHealth -= PLAYER_DAMAGE;
        debug_writeln("attacked enemy no.", enemyIndex,"! HP of enemy is ", enemies[enemyIndex].currentHealth);
        if (enemies[enemyIndex].currentHealth <= 0) {
            debug_writeln("Killed enemy no.", enemyIndex,"! removing...");
            enemies[enemyIndex].currentHealth = 0; // Mark as dead
        }
    }
}

void enemyTurn() {
    playerHealth -= ATTACK_DAMAGE;
}

void killAllEnemies() {
    enemies = enemies.filter!(e => e.currentHealth > 0).array(); // Convert FilterResult to an array
}