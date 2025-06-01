module dialogs.dialog_system;

import raylib;
import std.string;
import std.stdio;
import std.conv;
import std.uni;
import std.typecons;
import std.algorithm;

int currentPage = 0;
float textDisplayProgress = 0.0f;
bool textFullyDisplayed = false;

void displayDialog(string[] pages, int choicePage, Font dialogFont, bool *showDialog, float textSpeed) {
    int pagesLength = cast(int)pages.length;
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    
    // Draw dialog background
    DrawRectangle(
        0,
        screenHeight - screenHeight / 3,
        screenWidth,
        screenHeight / 3,
        Color(20, 20, 20, 220)
    );
    
    // Define text area margins
    float marginLeft = screenWidth/6.5f;
    float marginRight = screenWidth/6.5f;
    float marginTop = screenHeight - screenHeight/3.3f;
    float textWidth = screenWidth - marginLeft - marginRight;
    float fontSize = 40.0f;
    float spacing = 1.0f;
    
    // Handle text display progress
    string currentText = pages[currentPage];
    int textLength = cast(int)currentText.length;
    
    // If Enter is pressed and text isn't fully displayed, show all text immediately
    if (IsKeyPressed(KeyboardKey.KEY_ENTER) && !textFullyDisplayed) {
        textDisplayProgress = textLength;
        textFullyDisplayed = true;
    }
    // If text is fully displayed and Enter is pressed, go to next page
    else if (IsKeyPressed(KeyboardKey.KEY_ENTER) && textFullyDisplayed) {
        currentPage += 1;
        textDisplayProgress = 0.0f;
        textFullyDisplayed = false;
    }
    // Otherwise, increment text display progress
    else if (!textFullyDisplayed) {
        textDisplayProgress += textSpeed;
        if (textDisplayProgress >= textLength) {
            textDisplayProgress = textLength;
            textFullyDisplayed = true;
        }
    }
    
    // Get the portion of text to display
    int charsToShow = cast(int)textDisplayProgress;
    string displayedText = currentText[0 .. min(charsToShow, textLength)];
    
    // Split text into lines that fit within the available width
    string[] lines;
    string remainingText = displayedText;
    
    while (remainingText.length > 0) {
        // Measure how much text fits in one line
        int fitChars = 0;
        float width = 0.0f;
        
        while (fitChars < remainingText.length) {
            int nextChar = fitChars;
            while (nextChar < remainingText.length && !isWhite(remainingText[nextChar])) {
                nextChar++;
            }
            
            string word = remainingText[fitChars..nextChar];
            float wordWidth = MeasureTextEx(dialogFont, word.toStringz(), fontSize, spacing).x;
            
            if (width + wordWidth > textWidth && width > 0) {
                break; // Doesn't fit, break to new line
            }
            
            width += wordWidth;
            fitChars = nextChar;
            
            // Skip whitespace
            while (fitChars < remainingText.length && isWhite(remainingText[fitChars])) {
                width += MeasureTextEx(dialogFont, " ".toStringz(), fontSize, spacing).x;
                fitChars++;
            }
        }
        
        if (fitChars == 0) fitChars = 1; // Ensure progress
        
        lines ~= remainingText[0..fitChars];
        remainingText = remainingText[fitChars..$];
    }
    
    // Draw each line of text
    float lineHeight = MeasureTextEx(dialogFont, "A", fontSize, spacing).y * 1.4;
    for (int i = 0; i < lines.length; i++) {
        DrawTextEx(
            dialogFont,
            lines[i].toStringz(),
            Vector2(marginLeft, marginTop + i * lineHeight),
            fontSize,
            spacing,
            Colors.WHITE
        );
    }
    
    // Draw the snake animation (only when text is fully displayed)
    if (textFullyDisplayed) {
        drawSnakeAnimation(
            0,
            screenHeight - screenHeight / 3,
            screenWidth,
            screenHeight / 3
        );
    }
    
    // Handle page transitions
    if (currentPage >= pagesLength) {
        currentPage = 0;
        textDisplayProgress = 0.0f;
        textFullyDisplayed = false;
        pages = [];
        *showDialog = false;
        return;
    }
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
    
    for (int y = 0; y < cubesInRow; y++) {
        for (int x = 0; x < cubesInRow; x++) {
            DrawRectangle(
                centerX + x*(cubeSize + spacing),
                centerY + y*(cubeSize + spacing),
                cubeSize, cubeSize, Color(50, 50, 50, 255)
            );
        }
    }
    
    static int snakePosition = 0;
    if (animTimer == 0.0f) snakePosition = (snakePosition + 1) % 16;
    
    Tuple!(int, int)[] snakePath = [
        tuple(2, 0), tuple(3, 0), tuple(4, 0), tuple(4, 1),
        tuple(4, 2), tuple(4, 3), tuple(4, 4), tuple(3, 4),
        tuple(2, 4), tuple(1, 4), tuple(0, 4), tuple(0, 3),
        tuple(0, 2), tuple(0, 1), tuple(0, 0), tuple(1, 0)
    ];
    
    for (int i = 0; i < snakePath.length; i++) {
        int relPos = cast(int)((i + snakePosition) % snakePath.length);
        int x = snakePath[relPos][0];
        int y = snakePath[relPos][1];
        
        float t = cast(float)i / snakePath.length;
        Color cubeColor = Color(0, cast(ubyte)(50 + 70 * (1 - t)), 0, 255); 
        
        DrawRectangle(
            centerX + x*(cubeSize + spacing),
            centerY + y*(cubeSize + spacing),
            cubeSize, cubeSize, cubeColor
        );
    }
}