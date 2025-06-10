#include <raylib.h>
#include <stdio.h>

#include "../../include/variables.h"
#include "../../include/abstraction.h"

void load2Dcharacter(char* filename, int index, float scale, Vector2 coordinates) {
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
        Texture2D tex  = characterTexture.data[i].texture;
        float scale    = characterTexture.data[i].scale;
        float x        = characterTexture.data[i].x;
        float y        = characterTexture.data[i].y;

        if (tex.id != 0) {
            Rectangle srcRect  = { 0, 0, (float)tex.width, (float)tex.height };
            Rectangle dstRect  = { x, y, tex.width * scale, tex.height * scale };
            Vector2 origin     = { (tex.width * scale) * 0.5f, (tex.height * scale) * 0.5f };

            DrawTexturePro(
                tex,
                srcRect,
                dstRect,
                origin,
                0.0f,
                WHITE
            );
        }
    }
}
