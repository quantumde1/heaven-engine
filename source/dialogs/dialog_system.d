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
import std.array;
import std.algorithm;

int namewidth;

static void DrawTextBoxed(Font font, const char *text, Rectangle rec, float fontSize, float spacing, bool wordWrap, Color tint);   // Draw text using font inside rectangle limits
static void DrawTextBoxedSelectable(Font font, const char *text, Rectangle rec, float fontSize, float spacing, bool wordWrap, Color tint, int selectStart, int selectLength, Color selectTint, Color selectBackTint);    // Draw text using font inside rectangle limits with support for text selection

void display_dialog(string character, char* emotion, string[] pages, int choicePage) {
    uint image_size;
    char *image_data = get_file_data_from_archive("res/faces.bin", "test_good.png", &image_size);
    Texture2D dialogImage = LoadTextureFromImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size));
    UnloadImage(LoadImageFromMemory(".PNG", cast(const(ubyte)*)image_data, image_size));
    bool isGamepadConnected = IsGamepadAvailable(gamepadInt);
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    int paddingWidth = cast(int)(screenWidth * PADDING_RATIO);
    int paddingHeight = cast(int)(screenHeight * PADDING_RATIO);
    int rectWidth = screenWidth - (2 * paddingWidth);
    int rectHeight = screenHeight / 2 - (2 * paddingHeight);
    int rectX = paddingWidth;
    int rectY = screenHeight - rectHeight - paddingHeight;
    Color semiTransparentBlack = Color(0, 0, 0, 210); // RGBA: Black with 210 alpha
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
    string nameu = "["~character~"]";
    string currentPageText = pages[currentPage];
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

    int xPosition = rectX + charPaddingX + 10;
    int yPosition = lineY;
    Vector2 position = Vector2(xPosition, yPosition);
    if (nameu[1] == '#') {
        // Draw the character name
        namewidth = MeasureText(toStringz(to!string(nameu.filter!(x => x != '#'))), FONT_SIZE+10); // Measure the width of the nameu text
        DrawTextEx(fontdialog, toStringz(to!string(nameu.filter!(x => x != '#'))), position, FONT_SIZE, 1.0f, Colors.GREEN);
    }
    else {
        // Draw the character name
        namewidth = MeasureText(toStringz(nameu), FONT_SIZE+10); // Measure the width of the nameu text
        DrawTextEx(fontdialog, toStringz(nameu), position, FONT_SIZE, 1.0f, Colors.BLUE);
    }
    // Draw the current page text with wrapping
    Rectangle textBox = Rectangle(rectX + charPaddingX + 10 + namewidth, lineY, rectWidth - namewidth - charPaddingX - 10, rectHeight - charPaddingY);
    DrawTextBoxed(fontdialog, toStringz(currentPageText[0 .. currentCharIndex]), textBox, FONT_SIZE, 1.0f, true, Colors.WHITE);

    // Draw the image at the top right corner of the dialog box
    int imageX = cast(int)(rectX + rectWidth - (dialogImage.width * 3.5f) - 15); // Adjust the X position to the right corner
    int imageY = rectY - 337; // Adjust the Y position as needed
    DrawTextureEx(dialogImage, Vector2(imageX, imageY), 0.0f, 3.5f, Colors.WHITE);
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

    answer_num = -1; // Default value if incorrect

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
                } else {
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
            isTextureImageLoaded = false;
        }
    }

    event_initialized = showDialog;
}

void displayDialogs(Nullable!Cube collidedCube, char dlg, ref bool allowControl, ref bool showDialog, ref bool allow_exit_dialog, ref string name) {
    bool isCubeNotNull = !collidedCube.isNull;
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
                hintNeeded = false;
            } else {
                int fontSize = 20;
                DrawText(toStringz("Press "~dlg~" for dialog"), 40, posY, fontSize, Colors.BLACK);
                hintNeeded = false;
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

// Draw text using font inside rectangle limits
static void DrawTextBoxed(Font font, const char *text, Rectangle rec, float fontSize, float spacing, bool wordWrap, Color tint)
{
    DrawTextBoxedSelectable(font, text, rec, fontSize, spacing, wordWrap, tint, 0, 0, Colors.WHITE, Colors.WHITE);
}

// Draw text using font inside rectangle limits with support for text selection
static void DrawTextBoxedSelectable(Font font, const char *text, Rectangle rec, float fontSize, float spacing, bool wordWrap, Color tint, int selectStart, int selectLength, Color selectTint, Color selectBackTint)
{
    int length = TextLength(text);  // Total length in bytes of the text, scanned by codepoints in loop

    float textOffsetY = 0;          // Offset between lines (on line break '\n')
    float textOffsetX = 0.0f;       // Offset X to next character to draw

    float scaleFactor = fontSize/cast(float)font.baseSize;     // Character rectangle scaling factor

    // Word/character wrapping mechanism variables
    enum { MEASURE_STATE = 0, DRAW_STATE = 1 };
    int state = wordWrap? MEASURE_STATE : DRAW_STATE;

    int startLine = -1;         // Index where to begin drawing (where a line begins)
    int endLine = -1;           // Index where to stop drawing (where a line ends)
    int lastk = -1;             // Holds last value of the character position

    for (int i = 0, k = 0; i < length; i++, k++)
    {
        // Get next codepoint from byte string and glyph index in font
        int codepointByteCount = 0;
        int codepoint = GetCodepoint(&text[i], &codepointByteCount);
        int index = GetGlyphIndex(font, codepoint);

        // NOTE: Normally we exit the decoding sequence as soon as a bad byte is found (and return 0x3f)
        // but we need to draw all of the bad bytes using the '?' symbol moving one byte
        if (codepoint == 0x3f) codepointByteCount = 1;
        i += (codepointByteCount - 1);

        float glyphWidth = 0;
        if (codepoint != '\n')
        {
            glyphWidth = (font.glyphs[index].advanceX == 0) ? font.recs[index].width*scaleFactor : font.glyphs[index].advanceX*scaleFactor;

            if (i + 1 < length) glyphWidth = glyphWidth + spacing;
        }

        // NOTE: When wordWrap is ON we first measure how much of the text we can draw before going outside of the rec container
        // We store this info in startLine and endLine, then we change states, draw the text between those two variables
        // and change states again and again recursively until the end of the text (or until we get outside of the container).
        // When wordWrap is OFF we don't need the measure state so we go to the drawing state immediately
        // and begin drawing on the next line before we can get outside the container.
        if (state == MEASURE_STATE)
        {
            // TODO: There are multiple types of spaces in UNICODE, maybe it's a good idea to add support for more
            // Ref: http://jkorpela.fi/chars/spaces.html
            if ((codepoint == ' ') || (codepoint == '\t') || (codepoint == '\n')) endLine = i;

            if ((textOffsetX + glyphWidth) > rec.width)
            {
                endLine = (endLine < 1)? i : endLine;
                if (i == endLine) endLine -= codepointByteCount;
                if ((startLine + codepointByteCount) == endLine) endLine = (i - codepointByteCount);

                state = !state;
            }
            else if ((i + 1) == length)
            {
                endLine = i;
                state = !state;
            }
            else if (codepoint == '\n') state = !state;

            if (state == DRAW_STATE)
            {
                textOffsetX = 0;
                i = startLine;
                glyphWidth = 0;

                // Save character position when we switch states
                int tmp = lastk;
                lastk = k - 1;
                k = tmp;
            }
        }
        else
        {
            if (codepoint == '\n')
            {
                if (!wordWrap)
                {
                    textOffsetY += (font.baseSize + font.baseSize/2)*scaleFactor;
                    textOffsetX = 0;
                }
            }
            else
            {
                if (!wordWrap && ((textOffsetX + glyphWidth) > rec.width))
                {
                    textOffsetY += (font.baseSize + font.baseSize/2)*scaleFactor;
                    textOffsetX = 0;
                }

                // When text overflows rectangle height limit, just stop drawing
                if ((textOffsetY + font.baseSize*scaleFactor) > rec.height) break;

                // Draw selection background
                bool isGlyphSelected = false;
                if ((selectStart >= 0) && (k >= selectStart) && (k < (selectStart + selectLength)))
                {
                    DrawRectangleRec(Rectangle( rec.x + textOffsetX - 1, rec.y + textOffsetY, glyphWidth, cast(float)font.baseSize*scaleFactor ), selectBackTint);
                    isGlyphSelected = true;
                }

                // Draw current character glyph
                if ((codepoint != ' ') && (codepoint != '\t'))
                {
                    DrawTextCodepoint(font, codepoint, Vector2( rec.x + textOffsetX, rec.y + textOffsetY ), fontSize, isGlyphSelected? selectTint : tint);
                }
            }

            if (wordWrap && (i == endLine))
            {
                textOffsetY += (font.baseSize + font.baseSize/2)*scaleFactor;
                textOffsetX = 0;
                startLine = endLine;
                endLine = -1;
                glyphWidth = 0;
                selectStart += lastk - k;
                k = lastk;

                state = !state;
            }
        }

        if ((textOffsetX != 0) || (codepoint != ' ')) textOffsetX += glyphWidth;  // avoid leading spaces
    }
}