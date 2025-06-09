#include <raylib.h>
#include <stdio.h>

#include "../../include/variables.h"
#include "../../include/abstraction.h"

void load2Dcharacter(char* filename, int index, int scale, Vector2 coordinates) {
    while (index >= characterTexture.length) {
        CharacterTexture empty = {0};
        da_push(characterTexture, empty);
    }
    
    characterTexture.data[index].texture = LoadTexture(concat_strings(PREFIX, filename));
    characterTexture.data[index].scale = scale;
    characterTexture.data[index].x = coordinates.x;
    characterTexture.data[index].y = coordinates.y;
}

void draw2Dcharacter() {
    for (size_t i = 0; i < characterTexture.length; i++) {
        if (characterTexture.data[i].texture.id != 0) {
            float centeredX = characterTexture.data[i].x - (characterTexture.data[i].texture.width * characterTexture.data[i].scale / 2);
            float centeredY = characterTexture.data[i].y - (characterTexture.data[i].texture.height * characterTexture.data[i].scale / 2);
            
            DrawTextureEx(characterTexture.data[i].texture,
                        (Vector2){centeredX, centeredY}, 
                        0.0, 
                        characterTexture.data[i].scale, 
                        WHITE);
        }
    }
}