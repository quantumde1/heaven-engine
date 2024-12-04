//quantumde1 developed software, licensed under BSD-0-Clause license.
module ui.navigator;

import raylib;
import std.math;
import std.conv;

void draw_navigation(float cameraAngle, Font navFont) {
    const int compassSize = 200;
    const int compassX = GetScreenWidth() - compassSize - 20;
    const int compassY = 20;
    const int centerX = compassX + compassSize / 2;
    const int centerY = compassY + compassSize / 2;
    const float halfCompassSize = compassSize / 2.0f;
    const float angleRad = cameraAngle * DEG2RAD;
    DrawCircle(centerX, centerY, halfCompassSize, Colors.BLACK);
    DrawCircleLines(centerX, centerY, halfCompassSize, Colors.BLACK);
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