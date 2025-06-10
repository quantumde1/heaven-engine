#include "../../include/variables.h"

void resetAllValues() {
    luaExec = "";
    showDialog = 0;
    drawBackground = false;
    drawCharacter = false;
}

CharacterTextureArray characterTexture = {0};
Texture2DArray backgrounds = {0};
char** pages = {};
bool showDialog = false;
lua_State *L = NULL;

bool drawCharacter = false;
bool drawBackground = false;

int drawnBackgroundIndex = 0;

float typingSpeed = 0.6f;

Sound SFX;
Music BGM;

bool luaReload = true;

char* luaExec = "scripts/00_script.lua";
int pagesLength;
