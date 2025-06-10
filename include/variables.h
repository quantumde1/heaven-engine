#pragma once

#include <stdbool.h>
#include <raylib.h>
#ifdef _arch_dreamcast
#include <lua/lua.h>
#else
#include <lua5.3/lua.h>
#endif
#include <stdlib.h>

#ifdef _arch_dreamcast
#define PREFIX "/cd/"
#else
#define PREFIX ""
#endif

typedef struct {
    float x;
    float y;
    Texture2D texture;
    float scale;
} CharacterTexture;

typedef struct {
    CharacterTexture* data;
    size_t length;
    size_t capacity;
} CharacterTextureArray;

typedef struct {
    Texture2D* data;
    size_t length;
    size_t capacity;
} Texture2DArray;

#define da_init(arr, initial_capacity) do { \
    (arr).data = malloc((initial_capacity) * sizeof(*(arr).data)); \
    (arr).length = 0; \
    (arr).capacity = (initial_capacity); \
} while(0)

#define da_push(arr, item) do { \
    if ((arr).length >= (arr).capacity) { \
        (arr).capacity = (arr).capacity == 0 ? 4 : (arr).capacity * 2; \
        (arr).data = realloc((arr).data, (arr).capacity * sizeof(*(arr).data)); \
    } \
    (arr).data[(arr).length++] = (item); \
} while(0)

#define da_free(arr) do { free((arr).data); (arr).data = NULL; (arr).length = (arr).capacity = 0; } while(0)

extern CharacterTextureArray characterTexture;
extern Texture2DArray backgrounds;

extern char** pages;
extern bool showDialog;
extern lua_State *L;
extern bool drawBackground;
extern bool drawCharacter;

extern int drawnBackgroundIndex;

extern float typingSpeed;

extern int pagesLength;

extern Music BGM;

extern Sound SFX;

void resetAllValues();