// quantumde1 developed software, licensed under MIT license.
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
    if ((IsKeyPressed(KeyboardKey.KEY_DOWN)) || 
        (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN))) {
        if (numberOfButtons > 0) {
            debug debug_writeln("Selected button index: ", selectedButtonIndex, " buttonTextsInventory length:", 
            buttonTextsInventory[selectedTabIndex].length);
            if (selectedButtonIndex == 0 && buttonTextsInventory[selectedTabIndex].length == 1) {
                if (sfxEnabled) PlaySound(audio.nonSound);
            } else {
                if (sfxEnabled) PlaySound(audio.menuMoveSound);
                selectedButtonIndex = (selectedButtonIndex + 1) % numberOfButtons;
            }
        } else {
            if (sfxEnabled) PlaySound(audio.nonSound);
        }
    }
    if ((IsKeyPressed(KeyboardKey.KEY_UP)) || 
        (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP) )) {
        if (numberOfButtons > 0) {
            debug debug_writeln("Selected button index: ", selectedButtonIndex, " buttonTextsInventory length:", 
            buttonTextsInventory[selectedTabIndex].length);
            if (selectedButtonIndex == 0 && buttonTextsInventory[selectedTabIndex].length == 1) {
                if (sfxEnabled) PlaySound(audio.nonSound);
            } else {
                if (sfxEnabled) PlaySound(audio.menuMoveSound);
                selectedButtonIndex = (selectedButtonIndex - 1 + numberOfButtons) % numberOfButtons;
            }
        } else {
            if (sfxEnabled) PlaySound(audio.nonSound);
        }
    }
    if ((IsKeyPressed(KeyboardKey.KEY_RIGHT)) || 
        (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT) ) || 
        (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_TRIGGER_1) )) {
        if (sfxEnabled) PlaySound(audio.menuMoveSound);
        selectedTabIndex = (selectedTabIndex + 1) % numberOfTabs;
        selectedButtonIndex = 0;
    }
    if ((IsKeyPressed(KeyboardKey.KEY_LEFT)) || 
        (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT) ) || 
        (IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_TRIGGER_1) )) {
        if (sfxEnabled) PlaySound(audio.menuMoveSound);
        selectedTabIndex = (selectedTabIndex - 1 + numberOfTabs) % numberOfTabs;
        selectedButtonIndex = 0;
    }
    if (IsKeyPressed(KeyboardKey.KEY_BACKSPACE) || 
    IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT) ) {
        if (sfxEnabled) PlaySound(audio.declineSound);
        allowControl = true;
        showInventory = false;
        return;
    }
    if (IsKeyPressed(KeyboardKey.KEY_ENTER) || 
    IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) {
        
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
    DrawTextEx(fontdialog, "Paused", Vector2(screenWidth/2-(MeasureText("Paused", 30)/2), screenHeight/2), 30, 1.0f, 
    Colors.WHITE);
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
