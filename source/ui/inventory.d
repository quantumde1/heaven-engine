module ui.inventory;

import raylib;
import std.math;
import variables;
import std.stdio;
import graphics.cubes;
import std.conv;
import std.algorithm;
import scripts.config;
import std.string;
import ui.battle;

void drawInventory() {
    allowControl = false;
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    int barHeight = screenHeight / 9;
    Color semiTransparentBlack = Color(0, 0, 0, 210); // RGBA: Black with 210 alpha
    string[] menuTabs = ["Summon", "Return", "Skill", "Item", "System"];
    int numberOfTabs = cast(int)menuTabs.length;
    int tabWidth = screenWidth / numberOfTabs;
    DrawRectangleRounded(Rectangle(0, 0, screenWidth, barHeight), 0.03f, 16, semiTransparentBlack);
    // Draw the outline for the rounded rectangle
    DrawRectangleRoundedLinesEx(Rectangle(0, 0, screenWidth, barHeight), 0.03f, 16, 5.0f, Color(100, 54, 65, 255)); // Red color for the outline
    for (int i = 0; i < numberOfTabs; i++) {
        Color tabColor = (i == selectedTabIndex) ? semiTransparentBlack : Color(0, 0, 0, 150);
        DrawRectangle(i * tabWidth, 0, tabWidth, barHeight, tabColor);
        
        // Calculate the Y-coordinate for the text to be at the bottom left of the tab
        int textY = barHeight - 40; // Adjust this value for vertical positioning
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

    string[] buttonText = buttonTextsInventory[selectedTabIndex];
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
        
        // Draw the rounded rectangle for each button
        DrawRectangleRounded(Rectangle(rectX + buttonMargin, buttonY, rectWidth - (2 * buttonMargin), buttonHeight), 0.03f, 16, buttonColor);
        
        // Draw the button text
        DrawTextEx(fontdialog, toStringz(buttonText[i]), Vector2(rectX + buttonMargin + 10, buttonY + 4), 30, 1.0f, Colors.WHITE);
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
    if (IsKeyPressed(KeyboardKey.KEY_ENTER)  && selectedTabIndex == 4 && selectedButtonIndex == 1 || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN) && selectedTabIndex == 4 && selectedButtonIndex == 1) {
        currentGameState = GameState.Exit;
    }
    if (IsKeyPressed(KeyboardKey.KEY_BACKSPACE) || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT) ) {
        allowControl = true;
        showInventory = false;
        return;
    }
}
