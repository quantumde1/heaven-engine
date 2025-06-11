#include <raylib.h>

void drawRectangleWithCenteredText(int x, int y, Vector2 size, char* text, Color colorRectangle, Color colorText) {
    DrawRectangle(x, y, size.x, size.y, colorRectangle);
    
    int fontSize = 20;
    int textWidth = MeasureText(text, fontSize);
    
    int textX = x + (size.x - textWidth) / 2;
    int textY = y + (size.y - fontSize) / 2;
    
    DrawText(text, textX, textY, fontSize, colorText);
}

void gameMenu() {
    char* menuItems[5] = {"Continue", "Save", "Load", "Backlog", "Exit"};
    int startY = 20;
    for (int i = 0; i < 5; i++) {
        drawRectangleWithCenteredText(20, startY + i * 40, (Vector2){120, 60}, menuItems[i], SKYBLUE, WHITE);
    }
}