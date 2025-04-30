// quantumde1 developed software, licensed under MIT license.
module ui.common;

import raylib;
import std.string;
import std.conv;
import variables;
import scripts.config;

const int PLAYER_HEALTH_BAR_X = 10;
const float PLAYER_HEALTH_BAR_WIDTH = 300.0f;
const float PLAYER_HEALTH_BAR_HEIGHT = 30.0f;
const int PLAYER_HEALTH_BAR_Y_OFFSET = 600;

void drawPlayerHealthAndManaBar(int playerHealth, int maxPlayerHealth, int playerMana, int maxPlayerMana, float xOffset, float yOffset, float barWidth, float barHeight, string playerName) {
    float healthPercentage = cast(float)playerHealth / maxPlayerHealth;
    float manaPercentage = cast(float)playerMana / maxPlayerMana;

    // Увеличиваем высоту прямоугольника, чтобы вместить текст имени
    float totalHeight = barHeight * 2 + 30; // Увеличиваем высоту на 30 пикселей для текста имени
    DrawRectangleRounded(Rectangle(xOffset, yOffset, barWidth, totalHeight), 0.03f, 16, Color(0, 0, 0, 200));
    DrawRectangleRoundedLinesEx(Rectangle(xOffset, yOffset, barWidth, totalHeight), 0.03f, 16, 5.0f, Color(100, 54, 65, 255));

    // Текст здоровья и маны
    if (playerHealth <= 0) {
        string healthText = "EMPTY";
        Vector2 textSize = MeasureTextEx(fontdialog, toStringz(healthText), 30, 1.0f);
        float textX = xOffset + (barWidth - textSize.x) / 2; // Центрирование по горизонтали
        float textY = yOffset + (totalHeight - textSize.y) / 2; // Центрирование по вертикали
        DrawTextEx(fontdialog, toStringz(healthText), Vector2(textX, textY), 30, 1.0f, Colors.WHITE);
    } else {
        Vector2 nameTextSize = MeasureTextEx(fontdialog, toStringz(playerName), 20, 1.0f);
        float nameTextX = xOffset + (barWidth - nameTextSize.x) / 2; // Центрирование по горизонтали
        float nameTextY = yOffset + 5; // Размещение внутри прямоугольника (с небольшим отступом сверху)
        DrawTextEx(fontdialog, toStringz(playerName), Vector2(nameTextX, nameTextY), 20, 1.0f, Colors.WHITE);
        DrawRectangleRounded(Rectangle(xOffset + 5, yOffset + 30, cast(int)((barWidth - 10) * healthPercentage), barHeight - 10), 0.03f, 16, Colors.RED);
        DrawRectangleRounded(Rectangle(xOffset + 5, yOffset + barHeight + 30, cast(int)((barWidth - 10) * manaPercentage), barHeight - 10), 0.03f, 16, Colors.BLUE);
        string healthText = "HP: " ~ to!string(playerHealth) ~ "/" ~ to!string(maxPlayerHealth);
        DrawTextEx(fontdialog, toStringz(healthText), Vector2(xOffset + 10, yOffset + 30), 20, 1.0f, Colors.WHITE);
        string manaText = "MP: " ~ to!string(playerMana) ~ "/" ~ to!string(maxPlayerMana);
        DrawTextEx(fontdialog, toStringz(manaText), Vector2(xOffset + 10, yOffset + barHeight + 30), 20, 1.0f, Colors.WHITE);
    }
}

void drawPartyHealthAndManaBars() {
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    float barWidth = PLAYER_HEALTH_BAR_WIDTH; 
    float barHeight = PLAYER_HEALTH_BAR_HEIGHT;
    float spacing = 45.0f;

    int rows = 2;
    int columns = 3;

    float startX = screenWidth - (columns * (barWidth + 15)); 
    float startY = screenHeight - (rows * (barHeight * 2 + spacing));

    for (int i = 0; i < partyMembers.length; i++) {
        int row = i / columns;
        int col = i % columns;

        float xOffset = startX + col * (barWidth + 15.0f);
        float yOffset = startY + row * (barHeight * 2 + spacing);
        drawPlayerHealthAndManaBar(
            partyMembers[i].currentHealth,
            partyMembers[i].maxHealth,
            partyMembers[i].currentMana,
            partyMembers[i].maxMana,
            xOffset,
            yOffset,
            barWidth,
            barHeight,
            partyMembers[i].name
        );
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