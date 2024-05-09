module dialogs.dialog_system;

import raylib;

import std.conv;
import graphics.main_cycle;
import std.range;

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

void display_dialog(string character, int emotion, string[] pages) {
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
    int charPaddingX = charRectWidth / 6;
    int charPaddingY = charRectHeight / 2;
    DrawText(cast(char*)character, rectX + charRectWidth / 8, rectY - charRectHeight / 6, 20, Colors.WHITE);
    static int currentPage = 0;
    static int currentLine = 0;
    string currentPageText = pages[currentPage];
    string[] wrappedText = wrapText(currentPageText, GetFontDefault(), rectWidth - 2 * charPaddingX, 30);
    int lineY = rectY + charPaddingY + 10;
    foreach (line; wrappedText) {
        DrawText(line.ptr, rectX + charPaddingX + 10, lineY, 30, Colors.WHITE);
        lineY += cast(int)(MeasureTextEx(GetFontDefault(), " ", 30, 1).y) + 5;
        if (lineY > rectY + rectHeight - charPaddingY) {
            break;
        }
    }
    if (IsKeyPressed(KeyboardKey.KEY_ENTER)) {
        currentLine++;
        if (currentLine >= wrappedText.length) {
            currentPage++;
            currentLine = 0;
            if (currentPage >= pages.length) {
                showDialog = false;
                allowControl = true;
                allow_exit_dialog = true;
                currentPage = 0;
            }
        }
    }
}