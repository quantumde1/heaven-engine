module dialogs.dialog_system;

import raylib;
import std.stdio;
import std.conv;
import graphics.main_loop;
import std.range;
import variables;
import std.math;
import std.string;

// Constants for dialog display
enum int FONT_SIZE = 30;
enum float PADDING_RATIO = 1.0 / 9.0;
enum int CHAR_RECT_HEIGHT_RATIO = 5;
enum int CHAR_RECT_WIDTH_RATIO = 7;

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
            }
            currentLine = word; 
        }
    }

    if (currentLine.length > 0) {
        lines ~= currentLine; 
    }

    return lines;
}

void display_dialog(string character, int emotion, string[] pages, int choicePage) {
    if (choicePage == 0 && !rel) {
        writeln("no choice page");
        return;
    }

    string[] choices = ["test", "not test"];
    bool isGamepadConnected = IsGamepadAvailable(0);
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    int paddingWidth = cast(int)(screenWidth * PADDING_RATIO);
    int paddingHeight = cast(int)(screenHeight * PADDING_RATIO);
    int rectWidth = screenWidth - (2 * paddingWidth);
    int rectHeight = screenHeight / 2 - (2 * paddingHeight);
    int rectX = paddingWidth;
    int rectY = screenHeight - rectHeight - paddingHeight;

    // Draw dialog box
    DrawRectangleRounded(Rectangle(rectX, rectY, rectWidth, rectHeight), 0.2f, 16, Colors.GRAY);

    int charRectWidth = rectWidth / CHAR_RECT_WIDTH_RATIO;
    static int currentPage = 0;
    int charRectHeight = rectHeight / CHAR_RECT_HEIGHT_RATIO;
    DrawRectangleRounded(Rectangle(rectX - 30, rectY - 30, charRectWidth, charRectHeight), 0.2f, 16, Colors.BLACK);
    int charPaddingX = charRectWidth / 6;
    int charPaddingY = charRectHeight / 2;
    DrawText(toStringz(character), rectX + charRectWidth / 8, rectY - charRectHeight / 6, 20, Colors.WHITE);

    // Wrap and draw text
    string currentPageText = pages[currentPage];
    string[] wrappedText = wrapText(currentPageText, GetFontDefault(), rectWidth - 2 * charPaddingX, FONT_SIZE);
    int lineY = rectY + charPaddingY + 10;

    foreach (line; wrappedText) {
        DrawText(line.toStringz, rectX + charPaddingX + 10, lineY, FONT_SIZE, Colors.WHITE);
        lineY += MeasureText(cast(char*)line, FONT_SIZE) + 5;
        if (lineY > rectY + rectHeight - charPaddingY) {
            break;
        }
    }

    // Display input prompt
    int posY = GetScreenHeight() - 20 - 40;
    if (isGamepadConnected) {
        int buttonSize = 30;
        int circleCenterX = 40 + buttonSize / 2;
        int circleCenterY = posY + buttonSize / 2;
        DrawCircle(circleCenterX, circleCenterY, buttonSize / 2, Colors.GREEN);
        DrawText("A", circleCenterX - 5, circleCenterY - 7, 20, Colors.BLACK);
        DrawText(" to continue", 40 + buttonSize + 5, posY, 20, Colors.BLACK);
    } else {
        DrawText("Press enter to continue", 40, posY, 20, Colors.BLACK);
    }

    // Display choices if on the choice page
    int choiceY = lineY + 20;
    if (currentPage == choicePage) {
        for (int i = 0; i < choices.length; i++) {
            Color buttonColor = (i == selectedChoice) ? Colors.WHITE : Colors.LIGHTGRAY;
            DrawText(cast(char*)choices[i], rectX + charPaddingX + 10, choiceY, FONT_SIZE, buttonColor);
            choiceY += MeasureText(cast(char*)choices[i], FONT_SIZE) + 5;
        }

        // Handle input for choices
        if (IsKeyPressed(KeyboardKey.KEY_UP) || (isGamepadConnected && IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP))) {
            selectedChoice = cast(int)((selectedChoice - 1 + choices.length) % choices.length); // Wrap around
        }
        if (IsKeyPressed(KeyboardKey.KEY_DOWN) || (isGamepadConnected && IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN))) {
            selectedChoice = cast(int)((selectedChoice + 1) % choices.length); // Wrap around
        }
        if (IsKeyPressed(KeyboardKey.KEY_ENTER) || (isGamepadConnected && IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN))) {
            answer_num = selectedChoice;
        }
    }

    // Handle advancing the dialog
    if (IsKeyPressed(KeyboardKey.KEY_ENTER) || (isGamepadConnected && IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN))) {
        currentPage++;
        if (currentPage >= pages.length) {
            showDialog = false;
            allowControl = true;
            allow_exit_dialog = true;
            currentPage = 0;
        }
    }
}
