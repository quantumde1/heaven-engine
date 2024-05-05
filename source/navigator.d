module navigator;

import raylib;
import std.math;
import std.conv;

void draw_navigation(float cameraAngle) {
    int compassSize = 200;
    int compassX = GetScreenWidth() - compassSize - 20;
    int compassY = 20;
    int centerX = compassX + compassSize / 2;
    int centerY = compassY + compassSize / 2;
    DrawCircle(centerX, centerY, compassSize / 2, Colors.BLACK);
    Vector2[4] directions;
    directions[0] = Vector2(-sin(cameraAngle * DEG2RAD), cos(cameraAngle * DEG2RAD));
    directions[1] = Vector2(cos(cameraAngle * DEG2RAD), sin(cameraAngle * DEG2RAD));
    directions[2] = Vector2(sin(cameraAngle * DEG2RAD), -cos(cameraAngle * DEG2RAD));
    directions[3] = Vector2(-cos(cameraAngle * DEG2RAD), -sin(cameraAngle * DEG2RAD));
    char*[4] labels;
    labels[0] = cast(char*)"N";
    labels[1] = cast(char*)"E";
    labels[2] = cast(char*)"S";
    labels[3] = cast(char*)"W";
    for (int i = 0; i < 4; ++i) {
        Vector2 dirPos = Vector2(centerX + directions[i].x * (compassSize / 2 - 10), centerY - directions[i].y * (compassSize / 2 - 10));
        DrawLine(centerX, centerY, dirPos.x.to!int, dirPos.y.to!int, Colors.WHITE);
        DrawText(labels[i], int(dirPos.x.to!int - MeasureText(labels[i], 20) / 2), int(dirPos.y.to!int - 10), 20, Colors.RED);
    }
}
