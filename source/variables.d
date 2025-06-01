// quantumde1 developed software, licensed under MIT license.
module variables;

import std.typecons;
import raylib;
import bindbc.lua;

extern (C) char* get_file_data_from_archive(const char *input_file, const char *file_name, uint *file_size_out);

ControlConfig controlConfig;

/* character & npc */
bool hintNeeded;

bool playAnimation;

int currentFrame = 0;

Texture2D[] framesUI;

float frameDuration = 0.016f;

/* lua things */
lua_State* L;

/* interface things */
string ver = "1.1.0";
bool audioEnabled;
bool sfxEnabled = true;
bool fullscreenEnabled = true;
int gamepadInt;

/* dialogs */
bool showDialog = false;
int selectedChoice = 0;
int pageChoice_glob;
int answer_num;
bool isTextFullyDisplayed;
string[] message_global;
immutable int currentChoiceCharIndex = 0;
string[] choices; // To hold choices from Lua
Font fontdialog;
float typingSpeed;

/* audio things */
Music music;
char* musicpath;

struct TextureShow {
    float width;
    float height;
    float x;
    float y;
    Texture2D texture;
    float scale;
}

TextureShow[] tex2d;
Texture2D[] backgrounds;

/* controls */
struct ControlConfig {
    char right_button;
    char left_button;
    char back_button;
    char forward_button;
    char dialog_button;
    char opmenu_button;
}

int button;

/* main menu */

enum GameState {
    MainMenu,
    InGame,
    Exit
}

GameState currentGameState;
bool videoFinished;

/* models and locations */
Texture2D texture_background;
Texture2D texture_character;
bool neededDraw2D;
bool neededCharacterDrawing;

string lua_exec;
bool luaReload = true;
string usedLang = "english";

struct InterfaceAudio {
    Sound menuMoveSound;
    Sound menuChangeSound;
    Sound acceptSound;
    Sound declineSound;
    Sound nonSound;
}

InterfaceAudio audio;

void resetAllScriptValues() {
    import scripts.config : debug_writeln;
    debug_writeln("Resetting all values!");
    answer_num = 0;
    tex2d = [];
    backgrounds = [];
}