// quantumde1 developed software, licensed under BSD-0-Clause license.
module variables;

import graphics.cubes;
import std.typecons;
import raylib;
import bindbc.lua;
import raylib_lights;
import graphics.collision;

extern (C) char* get_file_data_from_archive(const char *input_file, const char *file_name, uint *file_size_out);

ControlConfig controlConfig;

int animations = 0;

/* camera related things */
Vector3 positionCam; // = Vector3(0.0f, 10.0f, 10.0f);    
Vector3 targetCam; // = Vector3(0.0f, 4.0f, 0.0f); 
Vector3 upCam; // = Vector3(0.0f, 1.0f, 0.0f);
Camera3D camera;
Camera3D oldCamera;
int encounterThreshold;
float radius;
float cameraAngle = 90.0f;
float deltaTime;
float neededDegree;
bool dungeonCrawlerMode;
float iShowSpeed;
float oldSpeed;
float oldDegree;
bool isCameraRotating = true;
Vector3 cameraTargetPosition;
float cameraMoveSpeed;
float cameraMoveDuration;
float cameraMoveElapsed;
int cubeIndex; // = cast(int)luaL_checkinteger(L, 1) - 1;
float targetAngle; // = cast(float) luaL_checknumber(L, 2);
float targetSpeed; // = cast(float) luaL_checknumber(L, 3);
float duration; // = cast(float) luaL_checknumber(L, 4);
bool runRotationCube;
bool shadersReload = true;

/* character & npc */
bool hintNeeded;
Vector3 cubePosition = { 0.0f, 0.0f, 0.0f };
Vector3 originalCubePosition;
Cube[] cubes; //massive of cubes
Nullable!Cube trackingCube; //check is we tracking any cube
bool isCubeMoving = false; //is any cube moving(except player)
float desiredDistance = 10.0f;//i forgot what it doing
int playerStepCounter = 0;
enum CubeSize = 2;
enum SpeedMultiplier = 2.0f;
int randomNumber;
Model playerModel;
char* playerModelName;
Model[] cubeModels;
Model[20] floorModel;
bool loadedShader;
float stamina = 25;

struct BattleState {
    int playerTurns;
    int enemyTurns;
    bool playerTurn; // true if it's the player's turn, false for enemies
}

// struct
struct Enemy {
    string name;
    Texture2D texture;
    int maxHealth;
    int currentHealth;
    int maxMana;
    int currentMana;
    int currentLevel;
    bool isShaking;
    float shakeTimer;
    Vector2 shakeOffset;
    int mood; // 0 - neutral, 1 - happy, 2 - scared, 3 - angry
    string[] initial_message;
    string[] questions;
    string[] answers;
}

string[] demonsAllowed;
Enemy[] enemies;

int XP;
BattleState battleState;
int selectedEnemyIndex = 0;
bool selectingEnemy = false;
bool inBattle = false;
bool isBossfight;
Texture2D background;
int selectedTabIndex = 0;
int secInBattle = false;
int playerMana = 30;
string[] demonsBossfightAllowed;
/* lua things */
lua_State* L;

/* interface things */
float flicker = 0.0;
bool increasing = true;
float ver = 1.0;
bool showInventory = false;
bool showMapPrompt = false;
bool showDebug = false;
bool audioEnabled;
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

struct PartyMember {
    int maxHealth;
    int currentHealth;
    int maxMana;
    int currentMana;
    string name;
    int level;
    int XP;
}

int currentPartyMemberIndex = 0;
PartyMember[6] partyMembers;
/* inventory */
string[][] buttonTexts = [
    ["Physical attack", "Gun attack", "Pass"], // Для вкладки "Attack"
    ["Agi 4MP", "Bufu 4MP", "Zio 3MP", "Dia 6MP"],  // Для вкладки "Magic"
    ["Medicine", "Dis-stun", "Dis-poison", "Revival bead"],
    ["Seduce", "Pester", "Default"],
    ["Rethreat"]
];

string[][] buttonTextsInventory;
string[] menuTabs;

float rotationStep = 1.6f;

int selectedButtonIndex = 0;
int selectedSubmenuButtonIndex = 0;

/* audio things */
Music music;
char* musicpath;
Music musicBattle;

struct TextureShow {
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
    Exit,
}

GameState currentGameState;
bool videoFinished;

/* lighting */
Light[] lights;

int modelAnimationWalk;
int modelAnimationIdle;
int modelAnimationRun;

/* models and locations */
Vector3[70] modelLocationSize;
Vector3[70] modelLocationRotate;
float[70] rotateAngle;
Vector3[70] modelPosition;
string location_name;
Texture2D texture_skybox;
bool friendlyZone;
Vector3 modelCharacterSize;
Vector3 collisionCharacterSize;
bool updateCamera = true;
Texture2D dialogImage;
Texture2D texture_background;
Texture2D texture_character;
bool neededDraw2D;
bool drawPlayer;
float modelCubeSize;
bool pos;
int FPS = 60;
Shader shader;
bool hideNavigation;
bool neededCharacterDrawing;
float rotationCube;
bool needRotationCube;
bool shaderEnabled = true;
char* fsdata;
char* vsdata;

/* textures */
char* model_location_path;
char* texture_model_location_path;

// Assign Shader to Models
void assignShaderToModel(Model model) {
    for (int i = 0; i < model.materialCount; i++) {
        model.materials[i].shader = shader;
    }
}

struct LightEngine {
    Vector3 lights;
    Color color;
}

LightEngine[] light_pos;

void resetAllScriptValues() {

}