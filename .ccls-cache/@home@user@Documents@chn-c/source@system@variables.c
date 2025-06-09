#include "../../include/variables.h"

CharacterTextureArray characterTexture = {0};
Texture2DArray backgrounds = {0};
char** pages = {};
bool showDialog = false;
lua_State *L = NULL;

bool drawCharacter = false;
bool drawBackground = false;

int drawnBackgroundIndex = 0;

float typingSpeed = 0.6f;

int pagesLength;
