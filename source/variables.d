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
float flicker = 0.0;
bool increasing = true;
string ver = "1.1.0";
bool showInventory = false;
bool showMapPrompt = false;
bool showDebug = false;
bool audioEnabled;
bool sfxEnabled = true;
bool fullscreenEnabled = true;
int gamepadInt;

/* dialogs */
bool allowControl = true; //for checking is control allowed at this moment
bool showDialog = false; //is dialog must be shown now
bool allow_exit_dialog = true; //can you exit from dialog
int selectedChoice = 0;
int pageChoice_glob;
int answer_num;
bool isTextFullyDisplayed;
char* emotion_global;
string name_global;
string[] message_global;
bool show_sec_dialog = false;
immutable int currentChoiceCharIndex = 0;
bool event_initialized;
string[] choices; // To hold choices from Lua
Font fontdialog;
// Constants for dialog display
enum int FONT_SIZE = 40;
enum float PADDING_RATIO = 1.0 / 9.0;
enum int CHAR_RECT_HEIGHT_RATIO = 5;
enum int CHAR_RECT_WIDTH_RATIO = 7;
float typingSpeed;

/* audio things */
Music music;
char* musicpath;
Music musicBattle;

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

char button;

/* main menu */

enum GameState {
    MainMenu,
    InGame,
    Exit
}

GameState currentGameState;
bool videoFinished;

int modelAnimationWalk = 0;
int modelAnimationIdle = 0;
int modelAnimationRun = 0;

/* models and locations */
Texture2D dialogImage;
Texture2D texture_background;
Texture2D texture_character;
bool neededDraw2D;
bool pos;
int FPS = 60;
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