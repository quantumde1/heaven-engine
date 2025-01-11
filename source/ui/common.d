module ui.common;

import raylib;
import std.string;
import std.conv;
import variables;

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