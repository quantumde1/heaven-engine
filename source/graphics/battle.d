// quantumde1 developed software, licensed under BSD-0-Clause license.
module graphics.battle;

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
import std.random;
import std.datetime;
import ui.common;

void loadAssets() {
    // Populating massive
    for (int i = 0; i < randomNumber; i++) {
        uint image_size;
        char *image_data = get_file_data_from_archive("res/tex.bin", "enemy_poltergheist.png", &image_size);
        enemies[i].texture = LoadTextureFromImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size));
        UnloadImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size));
        enemies[i].maxHealth = 30;
        enemies[i].currentHealth = enemies[i].maxHealth;
    }
    uint image_size;
    char *image_data = get_file_data_from_archive("res/bg.bin", "battle.png", &image_size);
    background = LoadTextureFromImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size));
    UnloadImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size));
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
    for (int i = 0; i < randomNumber; i++) {
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
    bool allEnemiesDefeated = true;

    foreach (enemy; enemies) {
        if (enemy.currentHealth > 0) {
            allEnemiesDefeated = false; // Found an enemy that is still alive
            break;
        }
    }
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
        uint seed = cast(uint)Clock.currTime().toUnixTime();
        auto rnd = Random(seed);
        int addXP = 5 * (randomNumber);
        int rectWidth = GetScreenWidth() / 3;
        int rectHeight = GetScreenHeight() / 2;
        int rectX = (GetScreenWidth() - rectWidth) / 2;
        int rectY = (GetScreenHeight() - rectHeight) / 2;

        DrawRectangleRounded(Rectangle(rectX, rectY, rectWidth, rectHeight), 0.03f, 16, semiTransparentBlack);
        DrawRectangleRoundedLinesEx(Rectangle(rectX, rectY, rectWidth, rectHeight), 0.03f, 16, 5.0f, Color(100, 54, 65, 255));
        
        // Начальная позиция Y для текста
        float textY = rectY + 30;

        DrawTextEx(fontdialog, "Results:", Vector2(rectX + 30, textY), 40, 1.0f, Colors.WHITE);
        textY += 50;
        DrawTextEx(fontdialog, toStringz("Achieved XP: " ~ to!string(addXP)), Vector2(rectX + 30, textY), 30, 1.0f, Colors.WHITE);
        textY += 40;

        DrawTextEx(fontdialog, toStringz("Current XP: " ~ to!string(XP+addXP)), Vector2(rectX + 30, textY), 30, 1.0f, Colors.WHITE);

        if (IsKeyPressed(KeyboardKey.KEY_ENTER)) {
            float fadeOutAlpha = 0.0f;
            while (fadeOutAlpha < 255) {
                fadeOutAlpha += 5;
                if (fadeOutAlpha > 255) fadeOutAlpha = 255;
                BeginDrawing();
                DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), Color(0, 0, 0, cast(ubyte)fadeOutAlpha));
                EndDrawing();
            }
            debug_writeln("Exiting from battle");
            for (int i = 0; i < randomNumber; i++) {
                for (int j = randomNumber; j < enemies.length - 1; j++) {
                    enemies[j] = enemies[j + 1];
                }
                UnloadTexture(enemies[i].texture);
            }
            randomNumber = uniform(1, 4, rnd);
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
                for (int i = 0; i < randomNumber; i++) {
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
            for (int i = 0; i < randomNumber; i++) {
                if (enemies[i].currentHealth > 0) {
                    selectedEnemyIndex = i;
                    break; // Exit the loop once a live enemy is found
                }
            }
        }
        if (IsKeyPressed(KeyboardKey.KEY_LEFT) || (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT))) {
            do {
                selectedEnemyIndex = (selectedEnemyIndex - 1 + randomNumber) % randomNumber;
            } while (enemies[selectedEnemyIndex].currentHealth <= 0);
            debug_writeln("Pressed left, counter: ", selectedEnemyIndex, " and enemy counter at all: ", randomNumber);
        }
        if (IsKeyPressed(KeyboardKey.KEY_RIGHT) || (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT))) {
            do {
                selectedEnemyIndex = (selectedEnemyIndex + 1) % randomNumber;
            } while (enemies[selectedEnemyIndex].currentHealth <= 0);
            debug_writeln("Pressed right, counter: ", selectedEnemyIndex, " and enemy counter at all: ", randomNumber);
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