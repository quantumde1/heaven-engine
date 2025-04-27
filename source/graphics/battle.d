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

Texture2D[] attackAnimationFrames;
int currentFrame = 0;
float frameTime = 0.0f;
const float frameDuration = 0.016f;
bool isPlayingAnimation = false;
bool isEnemyShaking = false;
float shakeDuration = 0.26f;
float shakeTimer = 0.0f;
Vector2 shakeOffset = Vector2(0, 0);

Texture2D[] loadAnimationFrames(const string archivePath, const string animationName) {
    Texture2D[] frames;
    uint frameIndex = 1;
    while (true) {
        string frameFileName = format("processed_%s_frame_%04d.png", animationName, frameIndex);
        uint image_size;
        debug debug_writeln(frameFileName);
        char* image_data = get_file_data_from_archive(cast(const(char)*)archivePath.ptr, cast(const(char)*)frameFileName.ptr, &image_size);
        if (image_data == null) {
            debug debug_writeln("exiting from load anim");
            break; // Если файл не найден, завершаем цикл
        }
        Image image = LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size);
        Texture2D texture = LoadTextureFromImage(image);
        UnloadImage(image);
        frames ~= texture;
        frameIndex++;
    }
    return frames;
}

void drawAttackAnimation() {
    if (isPlayingAnimation && currentFrame < attackAnimationFrames.length) {
        Texture2D currentTexture = attackAnimationFrames[currentFrame];
        Vector2 position = Vector2(
            (GetScreenWidth() - currentTexture.width * 6) / 2, // Учитываем увеличение масштаба
            (GetScreenHeight() - currentTexture.height * 6) / 2 // Учитываем увеличение масштаба
        );
        DrawTextureEx(currentTexture, position, 0, 6.0, Colors.WHITE); // Масштаб 3.0 вместо 1.0

        // Обновляем время кадра
        frameTime += GetFrameTime();
        if (frameTime >= frameDuration) {
            frameTime = 0.0f;
            currentFrame++;
            if (currentFrame >= attackAnimationFrames.length) {
                isPlayingAnimation = false;
                currentFrame = 0;
            }
        }
    }
}

import core.stdc.stdlib;
import core.stdc.time;
import std.json;
import std.file;

int[] demonNumber;

void loadAssets(string[] demons_filenames) {
    demonNumber = new int[randomNumber];
    for (int i = 0; i < randomNumber; i++) {
        demonNumber[i] = cast(int)(rand() % demons_filenames.length);
        JSONValue demon_data;
        if (!isBossfight) demon_data = parseJSON(readText("res/enemies_data/"~demons_filenames[demonNumber[i]]~".json"));
        else demon_data = parseJSON(readText("res/enemies_data/"~demonsBossfightAllowed[i]~".json"));
        uint image_size;
        char *image_data = get_file_data_from_archive(toStringz("res/enemies.bin"), 
        toStringz(demons_filenames[demonNumber[i]]~".png"), &image_size);
        enemies ~= Enemy(demon_data["name"].get!string, LoadTextureFromImage(LoadImageFromMemory(".PNG", 
        cast(const(ubyte)*)image_data, image_size)), demon_data["hp"].get!int, demon_data["hp"].get!int, 
        demon_data["mp"].get!int, demon_data["mp"].get!int);
    }

    uint image_size;
    char *image_data = get_file_data_from_archive("res/bg.bin", "battle.png", &image_size);
    background = LoadTextureFromImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size));
}

void initBattle(string[] demons_filenames) {
    // Setting states and loading assets
    loadAssets(demons_filenames);
    battleState.playerTurns = 1;
    battleState.playerTurn = true;

    // Load attack animation
    attackAnimationFrames = loadAnimationFrames("res/attack/SW_00.bin", "SW_00");
    isPlayingAnimation = false;
}

void exitBattle() {
    // Exit the battle if all enemies are defeated
    debug debug_writeln("Exiting from battle");
    for (int i = 0; i < randomNumber; i++) {
        for (int j = randomNumber; j < enemies.length - 1; j++) {
            enemies[j] = enemies[j + 1]; // Shift enemies left
        }
        UnloadTexture(enemies[i].texture); // Unload enemy texture
    }
    StopMusicStream(music);
    debug debug_writeln("Setting music to ", musicpath.to!string);
    
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
    static float spacing = 340.0f;
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

            // Вычитаем половину ширины и высоты текстуры для центрирования
            float textureHalfWidth = enemies[i].texture.width / 2.0f;
            float textureHalfHeight = enemies[i].texture.height / 2.0f;

            Color enemyColor = Colors.WHITE;
            if (i == selectedEnemyIndex && selectingEnemy) {
                float alpha = (sin(blinkTime) + 1) / 2;
                enemyColor = Color(cast(ubyte)255, cast(ubyte)255, cast(ubyte)0, cast(ubyte)cast(int)(alpha * 255));
            }

            // Обновление тряски для текущего врага
            if (enemies[i].isShaking) {
                enemies[i].shakeTimer += GetFrameTime();
                if (enemies[i].shakeTimer >= shakeDuration) {
                    enemies[i].isShaking = false;
                    enemies[i].shakeOffset = Vector2(0, 0); // Сбрасываем смещение после завершения тряски
                } else {
                    // Генерация случайного смещения для тряски
                    enemies[i].shakeOffset = Vector2(GetRandomValue(-10, 10), 0);
                }
            }

            // Применяем смещение для тряски
            Vector2 finalPosition = Vector2(posX - textureHalfWidth + enemies[i].shakeOffset.x, -200 + posY - textureHalfHeight + enemies[i].shakeOffset.y);

            // Рисуем текстуру с учетом центрирования и тряски
            DrawTextureEx(enemies[i].texture, finalPosition, 0, 5.0, enemyColor);
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
        debug debug_writeln("All enemies have been defeated! Victory!");
        drawBattleUI = false;
    }
}

void drawBattleMenu() {
    checkVictory();
    // Draw enemies on the screen
    drawEnemies();
    // Draw attack animation if playing
    drawAttackAnimation();
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
        drawPartyHealthAndManaBars();

        // Draw the button panel
        drawButtonPanel(rectX, rectY, rectWidth, rectHeight, buttonText, numberOfButtons, buttonHeight, buttonMargin);

        // Handle input for menu navigation
        handleMenuInput(numberOfButtons, numberOfTabs);
    }
    if (!isPlayingAnimation && !drawBattleUI) {
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

        if (IsKeyPressed(KeyboardKey.KEY_ENTER)
        || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) {
            float fadeOutAlpha = 0.0f;
            while (fadeOutAlpha < 255) {
                fadeOutAlpha += 5;
                if (fadeOutAlpha > 255) fadeOutAlpha = 255;
                BeginDrawing();
                DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), Color(0, 0, 0, cast(ubyte)fadeOutAlpha));
                EndDrawing();
            }
            debug debug_writeln("Exiting from battle");
            for (int i = 0; i < randomNumber; i++) {
                for (int j = randomNumber; j < enemies.length - 1; j++) {
                    enemies[j] = enemies[j + 1];
                }
                UnloadTexture(enemies[i].texture);
            }
            randomNumber = uniform(1, 4, rnd);
            if (audioEnabled) {
                StopMusicStream(music);
                debug debug_writeln("setting music to ",to!string(musicpath));
                uint audio_size;
                char *audio_data = get_file_data_from_archive("res/data.bin", musicpath, &audio_size);
                
                UnloadMusicStream(music);
                music = LoadMusicStreamFromMemory(".mp3", cast(const(ubyte)*)audio_data, audio_size);
                PlayMusicStream(music);
            }
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
            if (IsKeyPressed(KeyboardKey.KEY_ENTER) && selectedTabIndex == 0 && !selectingEnemy
            || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN)  && selectedTabIndex == 0 && !selectingEnemy) {
                debug debug_writeln("Enter pressed with selecting enemy to true");
                selectingEnemy = true;
                if (selectedEnemyIndex != enemies.length) {
                    if (enemies[selectedEnemyIndex].currentHealth == 0) {
                        debug debug_writeln("Enemy no.", selectedEnemyIndex, " destroyed!");
                    }
                } else {
                    debug debug_writeln("Enemy no x.", selectedEnemyIndex, " destroyed!");
                }
            } else if (selectingEnemy && IsKeyPressed(KeyboardKey.KEY_ENTER)
            || selectingEnemy && IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) {
                debug debug_writeln("enter pressed for acting");
                debug debug_writeln("current selected enemy(", selectedEnemyIndex ,") hp before attack is ", enemies[selectedEnemyIndex].currentHealth);
                performPhysicalAttack(selectedEnemyIndex);
                debug debug_writeln("current selected enemy(", selectedEnemyIndex ,") hp after attack is ", enemies[selectedEnemyIndex].currentHealth);
                debug debug_writeln("selecting enemy to false");
                for (int i = 0; i < randomNumber; i++) {
                    debug debug_writeln("HP of enemy[",i,"] is: ", enemies[i].currentHealth);
                    if (enemies[i].currentHealth > 0) {
                        debug debug_writeln("enemy turn!");
                        enemyTurn();
                        selectingEnemy = false;
                    } else {
                        debug debug_writeln("ignore");
                        selectingEnemy = false;
                    }
                }
            }
            break;
        default:
            break;
    }
    if (selectingEnemy) {
        if (selectedEnemyIndex != enemies.length) {
            if (enemies[selectedEnemyIndex].currentHealth == 0) {
                for (int i = 0; i < randomNumber; i++) {
                    if (enemies[i].currentHealth > 0) {
                        selectedEnemyIndex = i;
                        break; // Exit the loop once a live enemy is found
                    }
                }
            }
        } else {
            
        }
        if (IsKeyPressed(KeyboardKey.KEY_LEFT) || (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT))) {
            do {
                selectedEnemyIndex = (selectedEnemyIndex - 1 + randomNumber) % randomNumber;
            } while (enemies[selectedEnemyIndex].currentHealth <= 0);
            debug debug_writeln("Pressed left, counter: ", selectedEnemyIndex, " and enemy counter at all: ", randomNumber);
        }
        if (IsKeyPressed(KeyboardKey.KEY_RIGHT) || (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT))) {
            do {
                selectedEnemyIndex = (selectedEnemyIndex + 1) % randomNumber;
            } while (enemies[selectedEnemyIndex].currentHealth <= 0);
            debug debug_writeln("Pressed right, counter: ", selectedEnemyIndex, " and enemy counter at all: ", randomNumber);
        }
    }
}

// end of UI

// battle logic

void performPhysicalAttack(int enemyIndex) {
    if (enemies[enemyIndex].currentHealth > 0) {
        enemies[enemyIndex].currentHealth -= 15;
        debug debug_writeln("attacked enemy no.", enemyIndex,"! HP of enemy is ", enemies[enemyIndex].currentHealth, " player HP is ", partyMembers[0].currentHealth);
        if (enemies[enemyIndex].currentHealth <= 0) {
            debug debug_writeln("Killed enemy no.", enemyIndex,"! removing...");
            enemies[enemyIndex].currentHealth = 0; // Mark as dead
        }

        // Начинаем тряску только для атакованного врага
        enemies[enemyIndex].isShaking = true;
        enemies[enemyIndex].shakeTimer = 0.0f;

        // Start attack animation
        isPlayingAnimation = true;
        currentFrame = 0;
        frameTime = 0.0f;
    }
}

void enemyTurn() {
    // Проходим по всем врагам
    for (int i = 0; i < enemies.length; i++) {
        // Проверяем, жив ли текущий враг
        if (enemies[i].currentHealth > 0) {
            // Получаем данные о враге из JSON
            JSONValue demon_data = parseJSON(readText("res/enemies_data/"~demonsAllowed[demonNumber[i]]~".json"));
            int maxDamage = demon_data["maxDamage"].get!int;
            int minDamage = demon_data["minDamage"].get!int;

            // Выбираем случайного живого члена группы для атаки
            int[] livingMembers;
            foreach (j, member; partyMembers) {
                if (member.currentHealth > 0) {
                    livingMembers ~= cast(int)j; // Добавляем индекс живого члена группы
                }
            }

            // Если есть живые члены группы, выбираем случайного и атакуем
            if (!livingMembers.empty) {
                uint seed = cast(uint)Clock.currTime().toUnixTime();
                auto rnd = Random(seed);
                int randomIndex = uniform(0, cast(int)livingMembers.length, rnd);
                int randomPartyMember = livingMembers[randomIndex];

                // Наносим урон выбранному члену группы
                int damage = uniform(minDamage, maxDamage + 1, rnd); // Случайный урон в пределах minDamage и maxDamage
                partyMembers[randomPartyMember].currentHealth -= damage;

                debug debug_writeln("Enemy ", i, " attacked party member: ", randomPartyMember, " for ", damage, " damage.");
            } else {
                debug debug_writeln("All party members are dead. No attack performed by enemy ", i);
            }
        }
    }
}

void killAllEnemies() {
    enemies = enemies.filter!(e => e.currentHealth > 0).array(); // Convert FilterResult to an array
}