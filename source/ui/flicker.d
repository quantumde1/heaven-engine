// quantumde1 developed software, licensed under BSD-0-Clause license.
module ui.flicker;

import raylib;
import std.math;
import variables;

void draw_flickering_rhombus(int colorChoice, float intensity) {
    int rectWidth = 100; // Ширина прямоугольника
    int rectHeight = 100; // Высота прямоугольника
    int padding = 80;
    int rectX = padding; // X-координата
    int rectY = GetScreenHeight() - rectHeight - padding; // Y-координата

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
            break; // По умолчанию зеленый, если передано неизвестное значение
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
    if (!showInventory) {
        color.a = cast(char)(flicker * 255);
        DrawRectangle(rectX, rectY, rectWidth, rectHeight, Color(0, 0, 0, 200));
        DrawRectangleRoundedLinesEx(Rectangle(rectX, rectY, rectWidth, rectHeight), 0.03f, 16, 5.0f, Color(100, 54, 65, 255));
        DrawRectangle(rectX, rectY, rectWidth, rectHeight, color);
    }
}