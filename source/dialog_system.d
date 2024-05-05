module dialog_system;

import raylib;

import std.conv;

void display_dialog(string character, int emotion, string text) {
    int screenWidth = GetScreenWidth();
    int screenHeight = GetScreenHeight();
    int paddingWidth = screenWidth / 9;
    int paddingHeight = screenHeight / 9;
    int rectWidth = screenWidth - (2 * paddingWidth);
    int rectHeight = screenHeight / 2 - (2 * paddingHeight);
    int rectX = paddingWidth;
    int rectY = screenHeight - rectHeight - paddingHeight;
    DrawRectangle(rectX, rectY, rectWidth, rectHeight, Colors.GRAY);
    int charRectWidth = rectWidth / 7;
    int charRectHeight = rectHeight / 5;
    DrawRectangle(rectX - 30, rectY - 30, charRectWidth, charRectHeight, Colors.BLACK);
    int centerX = rectX + rectWidth / 2;
    int centerY = rectY + rectHeight / 2;
    Vector2 textSize = MeasureTextEx(GetFontDefault(), cast(char*)text, 30, 1);
    int textX = cast(int)(centerX - textSize.x / 2.0f);
    int textY = cast(int)(centerY - textSize.y / 2.0f);
    int charPaddingX = charRectWidth / 6;
    int charPaddingY = charRectHeight / 2;
    DrawText(cast(char*)character, rectX + charRectWidth / 8, rectY - charRectHeight / 6, 20, Colors.WHITE);
    DrawText(cast(char*)text, rectX+charPaddingX, rectY+charPaddingY, 30, Colors.WHITE);
    
}
