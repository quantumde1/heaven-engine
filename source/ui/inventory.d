module ui.inventory;

import raylib;
import std.math;
import variables;
import std.stdio;
import graphics.cubes;
import std.conv;
import std.algorithm;
import script;
import std.string;
import ui.battle_ui;

void drawInventory() {
    allowControl = false;
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    Color barColor = Colors.BLUE;
    int barHeight = screenHeight / 9;
    DrawRectangle(0, 0, screenWidth, barHeight, barColor);

    string[] menuTabs = ["Summon", "Return", "Skill", "Item", "System"];
    int numberOfTabs = cast(int)menuTabs.length;
    int tabWidth = screenWidth / numberOfTabs;

    for (int i = 0; i < numberOfTabs; i++) {
        Color tabColor = (i == selectedTabIndex) ? Colors.DARKGRAY : Colors.LIGHTGRAY;
        DrawRectangle(i * tabWidth, 0, tabWidth, barHeight, tabColor);
        DrawText(cast(char*)menuTabs[i], i * tabWidth + 10, 10, 20, Colors.WHITE);
    }

    if (IsKeyPressed(KeyboardKey.KEY_RIGHT) || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT) ) {
        selectedTabIndex = (selectedTabIndex + 1) % numberOfTabs;
        selectedButtonIndex = 0;
    }
    if (IsKeyPressed(KeyboardKey.KEY_LEFT) || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT)) {
        selectedTabIndex = (selectedTabIndex - 1 + numberOfTabs) % numberOfTabs;
        selectedButtonIndex = 0;
    }

    string[] buttonText = buttonTextsInventory[selectedTabIndex];
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

    if (IsKeyPressed(KeyboardKey.KEY_DOWN)|| IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN)) {
        selectedButtonIndex = (selectedButtonIndex + 1) % numberOfButtons;
    }
    if (IsKeyPressed(KeyboardKey.KEY_UP) || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP)) {
        selectedButtonIndex = (selectedButtonIndex - 1 + numberOfButtons) % numberOfButtons;
    }
    if (IsKeyPressed(KeyboardKey.KEY_BACKSPACE) ) {
        allowControl = true;
        showInventory = false;
        return;
    }
    drawPlayerHealthBar(playerHealth, 120);
}
