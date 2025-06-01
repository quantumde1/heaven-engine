// quantumde1 developed software, licensed under MIT license.
module dialogs.dialog_system;

import raylib;
import std.stdio;
import std.conv;
import graphics.engine;
import std.range;
import variables;
import std.math;
import std.string;
import std.typecons;
import std.array;
import std.algorithm;

int namewidth;

void displayDialog(string character, char* emotion, string[] pages, int choicePage) {
    bool isGamepadConnected = IsGamepadAvailable(gamepadInt);
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    
    int rectHeight = screenHeight / 3;
    int rectWidth = screenWidth;
    int rectX = 0;
    int rectY = screenHeight - rectHeight;
    
    // Semi-transparent dark gray background
    Color semiTransparentDarkGray = Color(20, 20, 20, 220); // Dark gray with 220 alpha
    DrawRectangle(rectX, rectY, rectWidth, rectHeight, semiTransparentDarkGray);
    
    int charRectWidth = rectWidth / CHAR_RECT_WIDTH_RATIO;
    static int currentPage = 0;
    int charRectHeight = rectHeight / CHAR_RECT_HEIGHT_RATIO;
    int charPaddingX = charRectWidth / 6;
    int charPaddingY = charRectHeight / 2;
    
    int padding = 37; // Uniform padding
    
    // Typing effect for the current page text
    static int currentCharIndex = 0;
    static float typingTimer = 0.0f;
    string nameu = "["~character~"]";
    string currentPageText = pages[currentPage];
    
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

    // Draw character name
    int nameX = rectX + padding;
    int nameY = rectY + padding;
    bool isI = (nameu.length > 1 && nameu[nameu.length-2] == 'i');
    
    if (character.length != 0) {
        if (nameu[1] == '#') {
            namewidth = MeasureText(toStringz(to!string(nameu.filter!(x => x != '#'))), FONT_SIZE+10);
            DrawTextEx(fontdialog, toStringz(to!string(nameu.filter!(x => x != '#'))), 
                      Vector2(nameX + 2, nameY + 2), FONT_SIZE, 1.0f, Colors.BLACK);
            DrawTextEx(fontdialog, toStringz(to!string(nameu.filter!(x => x != '#'))), 
                      Vector2(nameX, nameY), FONT_SIZE, 1.0f, Colors.GREEN);
        }
        else {
            namewidth = MeasureText(toStringz(nameu), FONT_SIZE+10);
            DrawTextEx(fontdialog, toStringz(nameu), Vector2(nameX + 2, nameY + 2), FONT_SIZE, 1.0f, Colors.BLACK);
            DrawTextEx(fontdialog, toStringz(nameu), Vector2(nameX, nameY), FONT_SIZE, 1.0f, Colors.BLUE);
        }
    }
    // Draw text with wrapping
    int textX = screenWidth/6 - (nameX + (isI ? namewidth + 30 : namewidth));
    int textY = nameY;
    int textWidth = rectWidth - textX - padding - screenWidth/6;
    int textHeight = rectHeight - padding * 2;
    
    Rectangle textBox = Rectangle(textX, textY, textWidth, textHeight);
    DrawTextBoxed(fontdialog, toStringz(currentPageText[0..currentCharIndex]), textBox, FONT_SIZE, 1.0f, true, Colors.WHITE);
    
    // Draw character image
    if (pos) {
        int imageX = cast(int)(rectX + rectWidth - (dialogImage.width * 3.5f) - 30);
        int imageY = cast(int)(rectY - dialogImage.height * 3.5f - 20);
        DrawTextureEx(dialogImage, Vector2(imageX, imageY), 0.0f, 3.5f, Colors.WHITE);
    } else {
        int imageX = cast(int)(rectX + 30);
        int imageY = cast(int)(rectY - dialogImage.height * 3.5f - 20);
        DrawTextureEx(dialogImage, Vector2(imageX, imageY), 0.0f, 3.5f, Colors.WHITE);
    }

    answer_num = -1; // Default value if incorrect

    // Display choices if on the choice page
    if (currentPage == choicePage) {
        // Set a fixed position for choices
        int choiceY = cast(int)(rectY + rectHeight - charPaddingY - (choices.length * (FONT_SIZE + 5)) - 20);
        for (int i = 0; i < choices.length; i++) {
            Color buttonColor = (i == selectedChoice) ? Colors.WHITE : Colors.LIGHTGRAY;
            DrawTextEx(fontdialog, (" "~choices[i]).toStringz, 
                        Vector2(rectX + charPaddingX + 10, choiceY + i * (FONT_SIZE + 5)), 
                        FONT_SIZE, 1.0f, buttonColor);
        }
        // Handle input for choices
        if (IsKeyPressed(KeyboardKey.KEY_UP) || (isGamepadConnected && IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP))) {
            if (sfxEnabled) PlaySound(audio.menuMoveSound);
            selectedChoice = cast(int)((selectedChoice - 1 + choices.length) % choices.length); // Wrap around
        }
        if (IsKeyPressed(KeyboardKey.KEY_DOWN) || (isGamepadConnected && IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN))) {
            if (sfxEnabled) PlaySound(audio.menuMoveSound);
            selectedChoice = cast(int)((selectedChoice + 1) % choices.length); // Wrap around
        }
        if (IsKeyPressed(KeyboardKey.KEY_ENTER) || (isGamepadConnected && IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN))) {
            if (sfxEnabled) PlaySound(audio.acceptSound);
            answer_num = selectedChoice;
        }
    }

    // Handle advancing the dialog
    if (isTextFullyDisplayed) {
        drawSnakeAnimation(rectX, rectY, rectWidth, rectHeight);
        // If the text is fully displayed, check for Enter key to go to the next page
        if (IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT) || IsKeyPressed(KeyboardKey.KEY_ENTER) || (isGamepadConnected && IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN))) {
            currentPage++;
            if (sfxEnabled) PlaySound(audio.acceptSound);
            currentCharIndex = 0; // Reset character index for the next page
            isTextFullyDisplayed = false; // Reset the text display state
            if (currentPage >= pages.length) {
                showDialog = false;
                allowControl = true;
                allow_exit_dialog = true;
                UnloadTexture(dialogImage);
                currentPage = 0; // Reset to the first page if needed
            }
        }
    } else {
        // If the text is not fully displayed, pressing Enter will show the full text
        if (IsKeyPressed(KeyboardKey.KEY_ENTER) || IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT) || (isGamepadConnected && IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN))) {
            isTextFullyDisplayed = true; // Set the flag to indicate the text is fully displayed
        }
    }

    event_initialized = showDialog;
}

void drawSnakeAnimation(int rectX, int rectY, int rectWidth, int rectHeight) {
    static float animTimer = 0.0f;
    animTimer += GetFrameTime();
    if (animTimer > 0.1f) animTimer = 0.0f;
    
    int animWidth = 300;
    int animHeight = 100;
    int animX = rectX + rectWidth - animWidth - 20;
    int animY = rectY + rectHeight - animHeight - 20;
    
    int cubeSize = 5;
    int cubesInRow = 5;
    int spacing = 1;
    
    int centerX = animX + animWidth/2 - (cubesInRow*cubeSize + (cubesInRow-1)*spacing)/2;
    int centerY = animY + animHeight/2 - (cubesInRow*cubeSize + (cubesInRow-1)*spacing)/2;
    
    // Рисуем фон (серые квадратики)
    for (int y = 0; y < cubesInRow; y++) {
        for (int x = 0; x < cubesInRow; x++) {
            DrawRectangle(
                centerX + x*(cubeSize + spacing),
                centerY + y*(cubeSize + spacing),
                cubeSize, cubeSize, Color(50, 50, 50, 255)
            );
        }
    }
    
    // Обновляем позицию змейки
    static int snakePosition = 0;
    if (animTimer == 0.0f) snakePosition = (snakePosition + 1) % 16;
    
    // Путь змейки
    Tuple!(int, int)[] snakePath = [
        tuple(2, 0), tuple(3, 0), tuple(4, 0), tuple(4, 1),
        tuple(4, 2), tuple(4, 3), tuple(4, 4), tuple(3, 4),
        tuple(2, 4), tuple(1, 4), tuple(0, 4), tuple(0, 3),
        tuple(0, 2), tuple(0, 1), tuple(0, 0), tuple(1, 0)
    ];
    
    // Рисуем змейку (зеленые квадратики)
    for (int i = 0; i < snakePath.length; i++) {
        int relPos = cast(int)((i + snakePosition) % snakePath.length);
        int x = snakePath[relPos][0];
        int y = snakePath[relPos][1];
        
        float t = cast(float)i / snakePath.length;
        Color cubeColor = Color(0, cast(ubyte)(50 + 70 * (1 - t)), 0, 255);  // G уменьшается к хвосту
        
        DrawRectangle(
            centerX + x*(cubeSize + spacing),
            centerY + y*(cubeSize + spacing),
            cubeSize, cubeSize, cubeColor
        );
    }
}

// Draw text using font inside rectangle limits
static void DrawTextBoxed(Font font, const char *text, Rectangle rec, float fontSize, float spacing, bool wordWrap, Color tint)
{
    DrawTextBoxedSelectable(font, text, rec, fontSize, spacing, wordWrap, tint, 0, 0, Colors.WHITE, Colors.WHITE);
}

static void DrawTextBoxedSelectable(Font font, const char *text, Rectangle rec, float fontSize, float spacing, bool wordWrap, Color tint, int selectStart, int selectLength, Color selectTint, Color selectBackTint)
{
    int length = TextLength(text);
    float textOffsetY = 0;
    float textOffsetX = 0.0f;
    float scaleFactor = fontSize/cast(float)font.baseSize; 
    enum { MEASURE_STATE = 0, DRAW_STATE = 1 };
    int state = wordWrap? MEASURE_STATE : DRAW_STATE;

    int startLine = -1;         // Index where to begin drawing (where a line begins)
    int endLine = -1;           // Index where to stop drawing (where a line ends)
    int lastk = -1;             // Holds last value of the character position

    for (int i = 0, k = 0; i < length; i++, k++)
    {
        int codepointByteCount = 0;
        int codepoint = GetCodepoint(&text[i], &codepointByteCount);
        int index = GetGlyphIndex(font, codepoint);

        if (codepoint == 0x3f) codepointByteCount = 1;
        i += (codepointByteCount - 1);

        float glyphWidth = 0;
        if (codepoint != '\n')
        {
            glyphWidth = (font.glyphs[index].advanceX == 0) ? font.recs[index].width*scaleFactor : font.glyphs[index].advanceX*scaleFactor;

            if (i + 1 < length) glyphWidth = glyphWidth + spacing;
        }
        if (state == MEASURE_STATE)
        {
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

                if ((textOffsetY + font.baseSize*scaleFactor) > rec.height) break;

                bool isGlyphSelected = false;
                if ((selectStart >= 0) && (k >= selectStart) && (k < (selectStart + selectLength)))
                {
                    DrawRectangleRec(Rectangle( rec.x + textOffsetX - 1, rec.y + textOffsetY, glyphWidth, cast(float)font.baseSize*scaleFactor ), selectBackTint);
                    isGlyphSelected = true;
                }
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