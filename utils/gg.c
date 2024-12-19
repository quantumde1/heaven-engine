#include "raylib.h"
#include <stdio.h> // Для использования printf
#include <math.h>  // Для использования sqrt и pow

#define MAX_POINTS 100
#define THRESHOLD 20.0f // Пороговое значение для определения "близости" точек

int main(void) {
    // Инициализация окна
    InitWindow(GetScreenWidth(), GetScreenHeight(), "raylib - Draw lines between points");
    ToggleFullscreen(); // Разворачиваем окно на весь экран

    // Загрузка текстуры фона
    Texture2D background = LoadTexture("background.png"); // Замените на путь к вашей текстуре
    Vector2 points[MAX_POINTS] = { 0 };
    int pointCount = 0;

    SetTargetFPS(60); // Устанавливаем частоту кадров
    int screenHeight = GetScreenHeight();
    int screenWidth = GetScreenWidth();
    
    while (!WindowShouldClose()) {
        // Проверяем нажатие мыши
        if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON) && pointCount < MAX_POINTS) {
            Vector2 newPoint = GetMousePosition();
            points[pointCount] = newPoint; // Добавляем новую точку в массив
            pointCount++;

            // Проверяем, находится ли новая точка рядом с существующими
            for (int i = 0; i < pointCount - 1; i++) {
                float distance = sqrt(pow(newPoint.x - points[i].x, 2) + pow(newPoint.y - points[i].y, 2));
                if (distance < THRESHOLD) {
                    points[pointCount - 1] = points[i]; // Устанавливаем последнюю добавленную точку на координаты ближайшей
                    break;
                }
            }
        }

        // Начинаем рисовать
        BeginDrawing();
        ClearBackground(RAYWHITE);
        Rectangle sourceRec = { 0, 0, (float)background.width, (float)background.height };
    
        // Define the destination rectangle (where to draw the texture on the screen)
        Rectangle destRec = { 0, 0, (float)screenWidth, (float)screenHeight };
        
        // Define the origin for rotation (in this case, it's the top-left corner)
        Vector2 origin = { 0, 0 };
        
        // Draw the texture with the specified parameters
        DrawTexturePro(background, sourceRec, destRec, origin, 0.0f, WHITE);

        // Рисуем линии между точками
        for (int i = 0; i < pointCount - 1; i++) {
            DrawLineV(points[i], points[i + 1], RED);
        }

        // Рисуем точки
        for (int i = 0; i < pointCount; i++) {
            DrawCircleV(points[i], 5, BLUE);
        }

        // Выводим конечные координаты последней точки
        if (pointCount > 0) {
            DrawText(TextFormat("Last Point: (%.2f, %.2f)", points[pointCount - 1].x, points[pointCount - 1].y), 10, 10, 20, BLACK);
        }

        EndDrawing();
    }

    // Освобождаем ресурсы
    UnloadTexture(background);

    // Вывод всех координат в формате Vector2
    printf("Coordinates of points:\n");
    for (int i = 0; i < pointCount; i++) {
        printf("Vector2(%.2f, %.2f)\n", points[i].x, points[i].y);
    }

    CloseWindow(); // Закрываем окно

    return 0;
}