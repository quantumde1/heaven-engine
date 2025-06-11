#include <raylib.h>

void drawRectangleWithCenteredText(Font font, int x, int y, Vector2 size, char* text, Color colorRectangle, Color colorText) {
    DrawRectangle(x, y, size.x, size.y, colorRectangle);
    
    int fontSize = 20;
    int textWidth = MeasureText(text, fontSize);
    
    int textX = x + (size.x - textWidth) / 2;
    int textY = y + (size.y - fontSize) / 2;
    
    DrawTextEx(font, text, (Vector2){textX, textY}, fontSize, 1.0f, colorText);
}

void gameMenu(Font font) {
    char* menuItems[5] = {"Continue", "Save", "Load", "Backlog", "Exit"};
    int startY = 20;
    for (int i = 0; i < 5; i++) {
        drawRectangleWithCenteredText(font, 23, startY + i * 40, (Vector2){140, 40}, menuItems[i], (Color){20, 20, 20, 220}, WHITE);
    }
}