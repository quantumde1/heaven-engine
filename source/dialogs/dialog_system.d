// quantumde1 developed software, licensed under BSD-0-Clause license.
module dialogs.dialog_system;

import raylib;
import std.stdio;
import std.conv;
import graphics.main_loop;
import std.range;
import variables;
import std.math;
import std.string;

// Function for wrapping text within a specified width
string[] wrapText(string text, Font font, float maxWidth, int fontSize) {
    string[] lines;
    string[] words = text.split(' ');
    string currentLine;

    foreach (word; words) {
        string testLine = currentLine.length > 0 ? currentLine ~ " " ~ word : word;
        Vector2 size = MeasureTextEx(font, testLine.ptr, fontSize, 1);
        if (size.x <= maxWidth) {
            currentLine = testLine;
        } else {
            if (currentLine.length > 0) {
                lines ~= currentLine;
                currentLine = word; 
            } else {
                lines ~= word;
                currentLine = "";
            }
        }
    }

    if (currentLine.length > 0) {
        lines ~= currentLine; 
    }

    return lines;
}

void display_dialog(string character, int emotion, string[] pages, int choicePage) {
    if (choicePage == 0) {
        if (!rel) {
            writeln("no choice page");
        }
    }
    string[] choices = ["test", "not test"];
    bool isGamepadConnected = IsGamepadAvailable(0);
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    int paddingWidth = screenWidth / 9;
    int paddingHeight = screenHeight / 9;
    int rectWidth = screenWidth - (2 * paddingWidth);
    int rectHeight = screenHeight / 2 - (2 * paddingHeight);
    int rectX = paddingWidth;
    int rectY = screenHeight - rectHeight - paddingHeight;

    // Draw rounded rectangle for the dialog box
    DrawRectangleRounded(Rectangle(rectX, rectY, rectWidth, rectHeight), 0.2f, 16, Colors.GRAY);

    int charRectWidth = rectWidth / 7;
    static int currentPage = 0;
    int charRectHeight = rectHeight / 5;
    DrawRectangleRounded(Rectangle(rectX - 30, rectY - 30, charRectWidth, charRectHeight), 0.2f, 16, Colors.BLACK);
    int charPaddingX = charRectWidth / 6;
    int charPaddingY = charRectHeight / 2;
    DrawText(toStringz(character), rectX + charRectWidth / 8, rectY - charRectHeight / 6, 20, Colors.WHITE);

    string currentPageText = pages[currentPage];
    string[] wrappedText = wrapText(currentPageText, GetFontDefault(), rectWidth - 2 * charPaddingX, 30);
    int lineY = rectY + charPaddingY + 10;

    foreach (line; wrappedText) {
        DrawText(line.toStringz, rectX + charPaddingX + 10, lineY, 30, Colors.WHITE);
        lineY += MeasureText(cast(char*)line, 30) + 5;
        if (lineY > rectY + rectHeight - charPaddingY) {
            break;
        }
    }

    // Display appropriate prompt based on input method
    int posY = GetScreenHeight() - 20 - 40;
    if (isGamepadConnected) {
        int buttonSize = 30;
        int circleCenterX = 40 + buttonSize / 2;
        int circleCenterY = posY + buttonSize / 2;
        int textYOffset = 7; // Adjust this offset based on your font and text size
        DrawCircle(circleCenterX, circleCenterY, buttonSize / 2, Colors.GREEN);
        DrawText("A", circleCenterX - 5, circleCenterY - textYOffset, 20, Colors.BLACK);
        DrawText(" to continue", 40 + buttonSize + 5, posY, 20, Colors.BLACK);
    } else {
        DrawText("Press enter to continue", 40, posY, 20, Colors.BLACK);
    }
    int choiceY = lineY + 20;
    if (currentPage == choicePage) {
        for (int i = 0; i < choices.length.to!int; i++) {
            Color buttonColor = (i == selectedChoice) ? Colors.WHITE : Colors.LIGHTGRAY;
            DrawText(cast(char*)choices[i], rectX + charPaddingX + 10, choiceY, 30, buttonColor);
            //writeln("selected button:", selectedChoice);
            choiceY += MeasureText(cast(char*)choices[i], 30) + 5;
        }
    }
    if (currentPage == choicePage) {
        if (currentPage == choicePage) {
            if (IsKeyPressed(KeyboardKey.KEY_UP) || (isGamepadConnected && IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP))) {
                selectedChoice = (selectedChoice - 1 + cast(int)choices.length) % cast(int)choices.length; // Wrap around
            }
            if (IsKeyPressed(KeyboardKey.KEY_DOWN) || (isGamepadConnected && IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN))) {
                selectedChoice = (selectedChoice + 1) % cast(int)choices.length; // Wrap around
            }
            if (IsKeyPressed(KeyboardKey.KEY_ENTER) || (isGamepadConnected && IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN))) {
                answer_num = selectedChoice;
            }

        }
    }
    if ((IsKeyPressed(KeyboardKey.KEY_ENTER) || (isGamepadConnected && IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN)))) {
        currentPage++;
        if (currentPage >= pages.length) {
            showDialog = false;
            allowControl = true;
            allow_exit_dialog = true;
            currentPage = 0;
        }
    }
}
