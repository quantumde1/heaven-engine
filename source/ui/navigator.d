//quantumde1 developed software, licensed under BSD-0-Clause license.
module ui.navigator;

import raylib;
import std.math;
import std.conv;

// Drawing arrow for compass
void draw_arrow(Vector2 start, Vector2 end, float size, Color color) {
    Vector2 direction = Vector2Subtract(end, start);
    Vector2 norm = Vector2Normalize(direction);
    Vector2 perp = Vector2(-norm.y, norm.x);
    Vector2 tip1 = Vector2Add(end, Vector2Scale(perp, size / 2));
    Vector2 tip2 = Vector2Subtract(end, Vector2Scale(perp, size / 2));
    Vector2 back = Vector2Subtract(end, Vector2Scale(norm, size));
    DrawLineEx(start, end, size / 10, color);
    DrawTriangle(end, tip1, back, color);
    DrawTriangle(end, back, tip2, color);
}

void draw_navigation(float cameraAngle) {
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
        DrawText(labels[i], int(dirPos.x.to!int - MeasureText(labels[i], 20) / 2), int(dirPos.y.to!int - 10), 20, labelColors[i]);
    }
}