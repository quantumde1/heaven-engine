#include <raylib.h>
#include <stdio.h>

#include "../../include/variables.h"
#include "../../include/abstraction.h"

#include <raylib.h>

void load2Dbackground(char* filename, int index) {
    while (index >= backgrounds.length) {
        Texture2D empty = {0};
        da_push(backgrounds, empty);
    }
    
    backgrounds.data[index] = LoadTexture(concat_strings(PREFIX, filename));
}

void draw2Dbackground(int index) {
    if (index < backgrounds.length && backgrounds.data[index].id != 0) {
        DrawTexturePro(backgrounds.data[index], 
                      (Rectangle){0, 0, (float)backgrounds.data[index].width, (float)backgrounds.data[index].height}, 
                      (Rectangle){0, 0, (float)GetScreenWidth(), (float)GetScreenHeight()}, 
                      (Vector2){0, 0}, 
                      0.0, 
                      WHITE);
    }
}