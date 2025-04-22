// quantumde1 developed software, licensed under BSD-0-Clause license.
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
import graphics.battle;
import ui.common;

void handleMenuInput(int numberOfButtons, int numberOfTabs) {
    if (inBattle) { 
        return;
    }
    // Handle input for navigating through buttons and tabs
    if ((IsKeyPressed(KeyboardKey.KEY_DOWN)) || 
        (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN) )) {
        selectedButtonIndex = (selectedButtonIndex + 1) % numberOfButtons;
    }
    if ((IsKeyPressed(KeyboardKey.KEY_UP)) || 
        (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP) )) {
        selectedButtonIndex = (selectedButtonIndex - 1 + numberOfButtons) % numberOfButtons;
    }
    if ((IsKeyPressed(KeyboardKey.KEY_RIGHT)) || 
        (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT) ) || 
        (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_TRIGGER_1) )) {
        selectedTabIndex = (selectedTabIndex + 1) % numberOfTabs;
        selectedButtonIndex = 0; // Reset button selection when changing tabs
    }
    if ((IsKeyPressed(KeyboardKey.KEY_LEFT)) || 
        (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT) ) || 
        (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_TRIGGER_1) )) {
        selectedTabIndex = (selectedTabIndex - 1 + numberOfTabs) % numberOfTabs;
        selectedButtonIndex = 0; // Reset button selection when changing tabs
    }
    if (IsKeyPressed(KeyboardKey.KEY_BACKSPACE) || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT) ) {
        allowControl = true;
        showInventory = false;
        return;
    }
    if (IsKeyPressed(KeyboardKey.KEY_ENTER) || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) {
        
    }
}

void drawInventory() {
    allowControl = false;
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    int barHeight = screenHeight / 9;
    Color semiTransparentBlack = Color(0, 0, 0, 210); // RGBA: Black with 210 alpha
    int numberOfTabs = cast(int)menuTabs.length;
    int tabWidth = screenWidth / numberOfTabs;
    string[] buttonText = buttonTextsInventory[selectedTabIndex];
    int numberOfButtons = cast(int)buttonText.length;
    int rectWidth = screenWidth / 4;
    int rectHeight = (2 * screenHeight) / 3;
    int rectX = 10;
    int rectY = barHeight + 15;

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

void configureTabs(string[] tabsNames) {
    menuTabs = tabsNames;
}

void addToTab(string whatToAdd, int countOfTab) {
    if (buttonTextsInventory.length <= countOfTab) {
        buttonTextsInventory.length += 1+ countOfTab - buttonTextsInventory.length;
    }
    buttonTextsInventory[countOfTab] ~= whatToAdd;
}
