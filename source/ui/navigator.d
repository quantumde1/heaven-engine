// quantumde1 developed software, licensed under BSD-0-Clause license.
module ui.navigator;

import raylib;
import std.math;
import std.conv;

void drawMoonState(int rectX, int rectY, int rectWidth, int rectHeight, Font fontdialog) {
    //New 	1/8 	2/8 	3/8 	Half 	5/8 	6/8 	7/8 	Full 
    immutable string[] moonPhases = [
        "New Moon",
        "1/8 Moon", //"Waxing Crescent",
        "2/8 Moon", //"First Quarter",
        "3/8 Moon", //"Waxing Gibbous",
        "Half Moon",
        "5/8 Moon",
        "6/8 Moon",
        "7/8 Moon",
        "Full Moon"
    ];
    static int currentPhase = 0;
    static float timeCounter = 0.0f;
    float changeInterval = 20.0f;

    timeCounter += GetFrameTime();
    if (timeCounter >= changeInterval) {
        timeCounter = 0.0f;
        currentPhase = cast(int)((currentPhase + 1) % moonPhases.length);
    }

    // Рисуем текст с фазой луны в прямоугольнике
    DrawTextEx(fontdialog, "Moon: ", Vector2(rectX + 10, rectY + 10), 20, 1.0f, Colors.WHITE);
    DrawTextEx(fontdialog, moonPhases[currentPhase].ptr, Vector2(rectX + 10, rectY + 40), 20, 1.0f, Colors.WHITE);
}

void drawCompass(const int compassSize, const int compassX, const int compassY, const int centerX, const int centerY, float cameraAngle, Font navFont) {
    const float halfCompassSize = compassSize / 2.0f;
    const float angleRad = cameraAngle * DEG2RAD;
    Vector2[4] directions = [
        Vector2(-sin(angleRad), cos(angleRad)),
        Vector2(cos(angleRad), sin(angleRad)),
        Vector2(sin(angleRad), -cos(angleRad)),
        Vector2(-cos(angleRad), -sin(angleRad))
    ];
    char*[4] labels = [
        cast(char*)"N",
        cast(char*)"E",
        cast(char*)"S",
        cast(char*)"W"
    ];
    Color[4] labelColors = [
        Colors.RED,    // N
        Colors.ORANGE, // E
        Colors.ORANGE, // S
        Colors.ORANGE  // W
    ];
    for (int i = 0; i < 4; ++i) {
        Vector2 dirPos = Vector2(centerX + directions[i].x * (halfCompassSize - 20), centerY - directions[i].y * (halfCompassSize - 20));
        DrawTextEx(navFont, labels[i], Vector2(int(dirPos.x.to!int - MeasureText(labels[i], 20) / 2), int(dirPos.y.to!int - 10)), 20, 1.0f, labelColors[i]);
    }
}

void draw_navigation(float cameraAngle, Font navFont, Font fontdialog) {
    const int compassSize = 200;
    const int compassX = GetScreenWidth() - compassSize - 20;
    const int compassY = 20;
    const int centerX = compassX + compassSize / 2;
    const int centerY = compassY + compassSize / 2;
    const float halfCompassSize = compassSize / 2.0f;
    DrawRectangle(cast(int)(centerX-halfCompassSize), cast(int)(centerY-halfCompassSize), 200, 270, Color(0, 0, 0, 200));
    DrawRectangleRoundedLinesEx(Rectangle(cast(int)(centerX-halfCompassSize), cast(int)(centerY-halfCompassSize), 200, 270), 0.03f, 16, 5.0f, Color(100, 54, 65, 255));
    drawMoonState(cast(int)(centerX - halfCompassSize), centerY + 100, 100, 100, fontdialog);
    drawCompass(compassSize, compassX, compassY, centerX, centerY, cameraAngle, navFont);
}