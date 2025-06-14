#include <raylib.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include "../../include/variables.h"
int currentPage = 0;
float textDisplayProgress = 0.0f;
bool textFullyDisplayed = false;

void drawSnakeAnimation(int rectX, int rectY, int rectWidth, int rectHeight);

void displayDialog(char** pages, int pagesLength, int choicePage, Font dialogFont, bool* showDialog, float textSpeed) {
    int screenWidth = 640;
    int screenHeight = 480;
    if (IsGamepadButtonDown(0, GAMEPAD_BUTTON_RIGHT_FACE_RIGHT)) {
        currentPage = 0;
        textDisplayProgress = 0.0f;
        textFullyDisplayed = false;
        *showDialog = false;
        return;
    }
    DrawRectangle(
        0,
        screenHeight - screenHeight / 3,
        screenWidth,
        screenHeight / 3,
        (Color){20, 20, 20, 220}
    );
    
    float marginLeft = screenWidth/6.5f;
    float marginRight = screenWidth/6.5f;
    float marginTop = screenHeight - screenHeight/3.3f;
    float textWidth = screenWidth - marginLeft - marginRight;
    
    float initialFontSize = 23.0f;
    float fontSize = initialFontSize;
    float spacing = 1.0f;
    
    const char* currentText = pages[currentPage];
    int textLength = strlen(currentText);
    
    if (IsKeyPressed(KEY_ENTER) || IsGamepadButtonPressed(0, GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) {
        if (!textFullyDisplayed) {
            textDisplayProgress = textLength;
            textFullyDisplayed = true;
        } else {
            currentPage += 1;
            textDisplayProgress = 0.0f;
            textFullyDisplayed = false;
        }
    }
    else if (!textFullyDisplayed) {
        textDisplayProgress += textSpeed;
        if (textDisplayProgress >= textLength) {
            textDisplayProgress = textLength;
            textFullyDisplayed = true;
        }
    }
    
    int charsToShow = (int)textDisplayProgress;
    if (charsToShow > textLength) charsToShow = textLength;
    
    char* displayedText = (char*)malloc(charsToShow + 1);
    strncpy(displayedText, currentText, charsToShow);
    displayedText[charsToShow] = '\0';
    
    bool textFits = false;
    float testFontSize = fontSize;
    int maxLines = 4;
    while (!textFits && testFontSize > 14.0f) {
        const char* testText = displayedText;
        int testLineCount = 0;
        bool fits = true;
        
        while (strlen(testText) > 0 && fits) {
            int fitChars = 0;
            float width = 0.0f;
            
            while (fitChars < strlen(testText) && fits) {
                int nextChar = fitChars;
                while (nextChar < strlen(testText) && !isspace(testText[nextChar])) {
                    nextChar++;
                }
                
                char word[nextChar - fitChars + 1];
                strncpy(word, testText + fitChars, nextChar - fitChars);
                word[nextChar - fitChars] = '\0';
                
                float wordWidth = MeasureTextEx(dialogFont, word, testFontSize, spacing).x;
                
                if (width + wordWidth > textWidth && width > 0) {
                    testLineCount++;
                    if (testLineCount >= maxLines) {
                        fits = false;
                        break;
                    }
                    width = 0.0f;
                    continue;
                }
                
                width += wordWidth;
                fitChars = nextChar;
                
                while (fitChars < strlen(testText) && isspace(testText[fitChars])) {
                    width += MeasureTextEx(dialogFont, " ", testFontSize, spacing).x;
                    fitChars++;
                }
            }
            
            if (!fits) break;
            
            testLineCount++;
            if (testLineCount > maxLines) {
                fits = false;
                break;
            }
            
            testText += fitChars;
        }
        
        if (fits) {
            textFits = true;
            fontSize = testFontSize;
        } else {
            testFontSize -= 2.0f;
        }
    }
    
    const char* remainingText = displayedText;
    char** lines = NULL;
    int lineCount = 0;
    float lineHeight = MeasureTextEx(dialogFont, "A", fontSize, spacing).y * 1.7f;
    
    while (strlen(remainingText) > 0) {
        int fitChars = 0;
        float width = 0.0f;
        
        while (fitChars < strlen(remainingText)) {
            int nextChar = fitChars;
            while (nextChar < strlen(remainingText) && !isspace(remainingText[nextChar])) {
                nextChar++;
            }
            
            char word[nextChar - fitChars + 1];
            strncpy(word, remainingText + fitChars, nextChar - fitChars);
            word[nextChar - fitChars] = '\0';
            
            float wordWidth = MeasureTextEx(dialogFont, word, fontSize, spacing).x;
            
            if (width + wordWidth > textWidth && width > 0) {
                break;
            }
            
            width += wordWidth;
            fitChars = nextChar;
            
            while (fitChars < strlen(remainingText) && isspace(remainingText[fitChars])) {
                width += MeasureTextEx(dialogFont, " ", fontSize, spacing).x;
                fitChars++;
            }
        }
        
        if (fitChars == 0) {
            fitChars = 1;
        }
        
        lines = (char**)realloc(lines, (lineCount + 1) * sizeof(char*));
        lines[lineCount] = (char*)malloc(fitChars + 1);
        strncpy(lines[lineCount], remainingText, fitChars);
        lines[lineCount][fitChars] = '\0';
        lineCount++;
        
        remainingText += fitChars;
    }
    
    int linesToShow = lineCount > maxLines ? maxLines : lineCount;
    if (currentPage == choicePage) {
        
        // Обработка выбора ответа (вверх/вниз)
        if (IsGamepadButtonPressed(0, GAMEPAD_BUTTON_LEFT_FACE_DOWN)) {
            dialogAnswerValue = (dialogAnswerValue + 1) % dialogAnswerLength;
        }
        if (IsGamepadButtonPressed(0, GAMEPAD_BUTTON_LEFT_FACE_UP)) {
            dialogAnswerValue = (dialogAnswerValue - 1 + dialogAnswerLength) % dialogAnswerLength;
        }
    
        for (int i = 0; i < dialogAnswerLength; i++) {
            Color color = (i == dialogAnswerValue) ? YELLOW : WHITE; 
            DrawTextEx(
                dialogFont,
                dialogAnswers[i],
                (Vector2){marginLeft, 40 + marginTop + i * 30},
                fontSize,
                spacing,
                color
            );
        }
    }
    for (int i = 0; i < linesToShow; i++) {
        DrawTextEx(
            dialogFont,
            lines[i],
            (Vector2){marginLeft, marginTop + i * lineHeight},
            fontSize,
            spacing,
            WHITE
        );
        free(lines[i]);
    }
    
    for (int i = linesToShow; i < lineCount; i++) {
        free(lines[i]);
    }
    
    free(lines);
    free(displayedText);
    
    if (textFullyDisplayed) {
        drawSnakeAnimation(
            0,
            screenHeight - screenHeight / 3,
            screenWidth,
            screenHeight / 3
        );
    }
    
    if (currentPage >= pagesLength) {
        currentPage = 0;
        textDisplayProgress = 0.0f;
        textFullyDisplayed = false;
        *showDialog = false;
        return;
    }
}

void drawSnakeAnimation(int rectX, int rectY, int rectWidth, int rectHeight) {
    static float animTimer = 0.0f;
    animTimer += GetFrameTime();
    if (animTimer > 0.1f) animTimer = 0.0f;
    
    // Фиксированный размер анимации
    int cubeSize = 5;
    int cubesInRow = 5;
    int spacing = 1;
    
    // Размер всей анимации
    int animWidth = cubesInRow * cubeSize + (cubesInRow - 1) * spacing;
    int animHeight = cubesInRow * cubeSize + (cubesInRow - 1) * spacing;
    
    // Позиция в правом нижнем углу прямоугольника диалога с отступом
    int animX = rectX + rectWidth - animWidth - 20;  // 20 пикселей от правого края
    int animY = rectY + rectHeight - animHeight - 20; // 20 пикселей от нижнего края
    
    // Рисуем фон (необязательно)
    DrawRectangle(animX, animY, animWidth, animHeight, (Color){20, 20, 20, 220});
    
    // Рисуем сетку
    for (int y = 0; y < cubesInRow; y++) {
        for (int x = 0; x < cubesInRow; x++) {
            DrawRectangle(
                animX + x * (cubeSize + spacing),
                animY + y * (cubeSize + spacing),
                cubeSize, cubeSize, (Color){50, 50, 50, 255}
            );
        }
    }
    
    static int snakePosition = 0;
    if (animTimer == 0.0f) snakePosition = (snakePosition + 1) % 16;
    
    typedef struct { int x; int y; } Point;
    Point snakePath[] = {
        {2, 0}, {3, 0}, {4, 0}, {4, 1},
        {4, 2}, {4, 3}, {4, 4}, {3, 4},
        {2, 4}, {1, 4}, {0, 4}, {0, 3},
        {0, 2}, {0, 1}, {0, 0}, {1, 0}
    };
    
    for (int i = 0; i < 16; i++) {
        int relPos = (i + snakePosition) % 16;
        int x = snakePath[relPos].x;
        int y = snakePath[relPos].y;
        
        float t = (float)i / 16.0f;
        Color cubeColor = (Color){0, (unsigned char)(50 + 70 * (1 - t)), 0, 255}; 
        
        DrawRectangle(
            animX + x * (cubeSize + spacing),
            animY + y * (cubeSize + spacing),
            cubeSize, cubeSize, cubeColor
        );
    }
}