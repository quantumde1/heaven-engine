// quantumde1 developed software, licensed under MIT license.
module variables;

import std.typecons;
import raylib;
import bindbc.lua;

extern (C) char* get_file_data_from_archive(const char *input_file, const char *file_name, uint *file_size_out);

void resetAllScriptValues() {
    import scripts.config : debug_writeln;
    debug_writeln("Resetting all values!");
    answerIndex = 0;
    tex2d = [];
    backgrounds = [];
}

/* system */

struct ControlConfig {
    char right_button;
    char left_button;
    char back_button;
    char forward_button;
    char dialog_button;
    char opmenu_button;
}

struct CharacterTexture {
    float width;
    float height;
    float x;
    float y;
    Texture2D texture;
    float scale;
}

struct InterfaceAudio {
    Sound menuMoveSound;
    Sound menuChangeSound;
    Sound acceptSound;
    Sound declineSound;
    Sound nonSound;
}

enum GameState {
    MainMenu,
    InGame,
    Exit
}

CharacterTexture[] tex2d;

ControlConfig controlConfig;

InterfaceAudio audio;

GameState currentGameState;

Font textFont;

Music music;


/* booleans */

bool hintNeeded;

bool playAnimation;

bool audioEnabled;

bool sfxEnabled = true;

bool fullscreenEnabled = true;

bool luaReload = true;

bool videoFinished;

bool neededDraw2D;

bool neededCharacterDrawing;

bool showDialog = false;

bool isTextFullyDisplayed;


/* strings */

string ver = "1.1.8";

string[] messageGlobal;

string[] choices;

string luaExec;

string usedLang = "english";

char* musicPath;


/* floats */

float frameDuration = 0.016f;

float typingSpeed = 0.6f;


/* textures */

Texture2D[] backgrounds;

Texture2D[] framesUI;

Texture2D backgroundTexture;

/* integer values */

int button;

int selectedChoice = 0;

int pageChoice_glob;

int answerIndex;

int currentFrame = 0;

int currentChoiceCharIndex = 0;

int gamepadInt;


/* lua */

lua_State* L;