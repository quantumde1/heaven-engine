module ui.flicker;

import raylib;
import std.math;
import variables;

void draw_flickering_rhombus(int colorChoice, float intensity) {
    int rhombusSize = 150;
    int padding = 20;
    int rhombusX = padding;
    int rhombusY = GetScreenHeight() - rhombusSize - padding;
    int centerX = rhombusX + rhombusSize / 2;
    int centerY = rhombusY + rhombusSize / 2;
    Color color;
    switch (colorChoice) {
        case 0:
            color = Colors.GREEN;
            break;
        case 1:
            color = Colors.YELLOW;
            break;
        case 2:
            color = Colors.ORANGE;
            break;
        case 3:
            color = Colors.RED;
            break;
        default:
            color = Colors.GREEN;
            break; // Default to green if an unknown value is passed
    }
    if (increasing) {
        flicker += GetFrameTime();
        if (flicker >= 1.0) {
            flicker = 1.0;
            increasing = false;
        }
    } else {
        flicker -= GetFrameTime();
        if (flicker <= 0.0) {
            flicker = 0.0;
            increasing = true;
        }
    }
    color.a = cast(char)(flicker * 255);
    Vector2[4] points = [
        Vector2(centerX, centerY - rhombusSize / 2),
        Vector2(centerX + rhombusSize / 2, centerY),
        Vector2(centerX, centerY + rhombusSize / 2),
        Vector2(centerX - rhombusSize / 2, centerY)
    ];
    DrawPoly(Vector2(centerX+20, centerY-20), 4, rhombusSize / 2, 45.0f, color);
}