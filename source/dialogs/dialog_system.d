module dialogs.dialog_system;

import raylib;
import std.stdio;
import std.conv;
import graphics.main_loop;
import std.range;
import variables;
import std.math;
import std.string;
import std.typecons;
import graphics.cubes;

void display_dialog(string character, int emotion, string[] pages, int choicePage) {
    if (choicePage == 0 && !rel) {
        writeln("no choice page");
        return;
    }
    
    bool isGamepadConnected = IsGamepadAvailable(gamepadInt);
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    int paddingWidth = cast(int)(screenWidth * PADDING_RATIO);
    int paddingHeight = cast(int)(screenHeight * PADDING_RATIO);
    int rectWidth = screenWidth - (2 * paddingWidth);
    int rectHeight = screenHeight / 2 - (2 * paddingHeight);
    int rectX = paddingWidth;
    int rectY = screenHeight - rectHeight - paddingHeight;
    Color semiTransparentBlack = Color(0, 0, 0, 210); // RGBA: Black with 150 alpha (out of 255)
    DrawRectangleRounded(Rectangle(rectX, rectY, rectWidth, rectHeight), 0.03f, 16, semiTransparentBlack);
    float lineThickness = 5.0f; // Set the desired line thickness
    DrawRectangleRoundedLines(Rectangle(rectX, rectY, rectWidth, rectHeight), 0.03f, 16, lineThickness, Color(100, 54, 65, 255)); // Red color
    int charRectWidth = rectWidth / CHAR_RECT_WIDTH_RATIO;
    static int currentPage = 0;
    int charRectHeight = rectHeight / CHAR_RECT_HEIGHT_RATIO;
    int charPaddingX = charRectWidth / 6;
    int charPaddingY = charRectHeight / 2;
    // Typing effect for the current page text
    static int currentCharIndex = 0; // Index of the current character being displayed
    static float typingTimer = 0.0f; // Timer for typing effect
    //float typingSpeed = 0.03f; // Time in seconds between each character
    // Format the current page text
    string currentPageText = formatText(pages[currentPage]);
    int lineY = rectY + charPaddingY + 10;

    // Update typing effect
    if (!isTextFullyDisplayed) {
        if (currentCharIndex < currentPageText.length) {
            typingTimer += GetFrameTime();
            if (typingTimer >= typingSpeed) {
                currentCharIndex++;
                typingTimer = 0.0f;
            }
        } else {
            isTextFullyDisplayed = true;
        }
    } else {
        currentCharIndex = cast(int)currentPageText.length;
    }

    // Draw the text with typing effect
    string nameu = "["~character~"]";
    int nameuWidth = MeasureText(toStringz(nameu), FONT_SIZE+10); // Measure the width of the nameu text
    int xPosition = rectX + charPaddingX + 10;
    int yPosition = lineY;

    // Create a Vector2 instance for the position
    Vector2 position = Vector2(xPosition, yPosition);

    // Draw the character name
    DrawTextEx(fontdialog, toStringz(nameu), position, FONT_SIZE, 1.0f, Colors.BLUE);

    // Draw the current page text
    DrawTextEx(fontdialog, toStringz(currentPageText[0 .. currentCharIndex]), 
                Vector2(rectX + charPaddingX + 10 + nameuWidth, lineY), 
                FONT_SIZE, 1.0f, Colors.WHITE);

    // Display input prompt
    int posY = GetScreenHeight() - 20 - 40;
    if (isGamepadConnected) {
        int buttonSize = 30;
        int circleCenterX = 40 + buttonSize / 2;
        int circleCenterY = posY + buttonSize / 2;
        DrawCircle(circleCenterX, circleCenterY, buttonSize / 2, Colors.GREEN);
        DrawTextEx(fontdialog, toStringz("A"), Vector2(circleCenterX - 5, circleCenterY - 7), 25, 1.0f, Colors.BLACK);
        DrawTextEx(fontdialog, toStringz(" to continue"), Vector2(40 + buttonSize + 5, posY), 25, 1.0f, Colors.BLACK);
    } else {
        DrawTextEx(fontdialog, toStringz("Press enter to continue"), Vector2(40, posY), 25, 1.0f, Colors.BLACK);
    }

    answer_num = -1; //default value if incorrect

    // Display choices if on the choice page
    if (currentPage == choicePage) {
        // Set a fixed position for choices
        int choiceY = cast(int)(rectY + rectHeight - charPaddingY - (choices.length * (FONT_SIZE + 5)) - 20); // Adjust the -20 as needed for spacing
        for (int i = 0; i < choices.length; i++) {
            Color buttonColor = (i == selectedChoice) ? Colors.WHITE : Colors.LIGHTGRAY;
            DrawTextEx(fontdialog, (" "~choices[i]).toStringz, 
                        Vector2(rectX + charPaddingX + 10, choiceY + i * (FONT_SIZE + 5)), 
                        FONT_SIZE, 1.0f, buttonColor);
        }
        // Handle input for choices
        if (IsKeyPressed(KeyboardKey.KEY_UP) || (isGamepadConnected && IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP))) {
            selectedChoice = cast(int)((selectedChoice - 1 + choices.length) % choices.length); // Wrap around
        }
        if (IsKeyPressed(KeyboardKey.KEY_DOWN) || (isGamepadConnected && IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN))) {
            selectedChoice = cast(int)((selectedChoice + 1) % choices.length); // Wrap around
        }
        if (IsKeyPressed(KeyboardKey.KEY_ENTER) || (isGamepadConnected && IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN))) {
            answer_num = selectedChoice;
        }
    }

    // Handle advancing the dialog
    if (isTextFullyDisplayed) {
        // If the text is fully displayed, check for Enter key to go to the next page
        if (IsKeyPressed(KeyboardKey.KEY_ENTER) || (isGamepadConnected && IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN))) {
            currentPage++;
            currentCharIndex = 0; // Reset character index for the next page
            isTextFullyDisplayed = false; // Reset the text display state
            if (currentPage >= pages.length) {
                
                if (battleDialog) {
                    battleDialog = false;
                    showDialog = false;
                    allow_exit_dialog = true;
                }
                else {
                    showDialog = false;
                    allowControl = true;
                    allow_exit_dialog = true;
                }
                currentPage = 0; // Reset to the first page if needed
            }
        }
    } else {
        // If the text is not fully displayed, pressing Enter will show the full text
        if (IsKeyPressed(KeyboardKey.KEY_ENTER) || (isGamepadConnected && IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN))) {
            isTextFullyDisplayed = true; // Set the flag to indicate the text is fully displayed
        }
    }

    event_initialized = showDialog;
}

// Helper function to format text
string formatText(string text) {
    // Split the text into lines of a maximum of 88 characters
    string formattedText;
    int length = cast(int)text.length;
    for (int i = 0; i < length; i += 54) {
        int end = i + 54 < length ? i + 54 : length;
        formattedText ~= text[i .. end];
        
        // Check if the next segment is not the end of the text
        if (end < length) {
            // Check if the next segment starts with a word (not whitespace)
            if (text[end] != ' ' && text[end] != '\n') {
                formattedText ~= "-\n\n\n"; // Add hyphen and newline if not at the end
            } else {
                formattedText ~= "\n\n\n"; // Just add newline if at the end
            }
        }
    }
    return formattedText;
}

void displayDialogs(Nullable!Cube collidedCube, char dlg, ref bool allowControl, ref bool showDialog, ref bool allow_exit_dialog, ref string name) {
    bool isCubeNotNull = !collidedCube.isNull;
    import std.string : toStringz;
    int posY = GetScreenHeight() - 20 - 40;
    // Check if cube collision is not null
    if (isCubeNotNull) {
        if (!showDialog && allow_exit_dialog && !inBattle) {
            if (IsGamepadAvailable(gamepadInt)) {
                int buttonSize = 30;
                int circleCenterX = 40 + buttonSize / 2;
                int circleCenterY = posY + buttonSize / 2;
                int textYOffset = 7; // Adjust this offset based on your font and text size
                DrawCircle(circleCenterX, circleCenterY, buttonSize / 2, Colors.RED);
                DrawText(("B"), circleCenterX - 5, circleCenterY - textYOffset, 20, Colors.BLACK);
                DrawText((" to dialog"), 40 + buttonSize + 5, posY, 20, Colors.BLACK);
            } else {
                int fontSize = 20;
                DrawText(toStringz("Press "~dlg~" for dialog"), 40, posY, fontSize, Colors.BLACK);
            }
        }

        // If all correct, show dialog from script with all needed text, name, emotion etc
        if (IsKeyPressed(dlg) || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT)) {
            if (allow_exit_dialog) {
                allow_exit_dialog = false;
                allowControl = false;
                name = collidedCube.get.name;
                showDialog = true;
                // Set the global variables to the current cube's dialog
                name_global = collidedCube.get.name;
                message_global = collidedCube.get.text;
                emotion_global = collidedCube.get.emotion;
                pageChoice_glob = collidedCube.get.choicePage;
            }
        }
    }

    // If dialog is not ended (not all text pages showed), show up "Press enter for continue" for showing next page of text
    if (showDialog && isCubeNotNull) {
        display_dialog(name_global, emotion_global, message_global, pageChoice_glob);
    }
}
