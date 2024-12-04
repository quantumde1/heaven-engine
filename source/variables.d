module variables;

import graphics.cubes;
import std.typecons;
import raylib;
import bindbc.lua;
import raylib_lights;

extern (C) char* get_file_data_from_archive(const char *input_file, const char *file_name, uint *file_size_out);

/* camera related things */
Vector3 positionCam; // = Vector3(0.0f, 10.0f, 10.0f);    
Vector3 targetCam; // = Vector3(0.0f, 4.0f, 0.0f); 
Vector3 upCam; // = Vector3(0.0f, 1.0f, 0.0f);
Camera3D camera;
Vector3 originalCameraPosition;
Vector3 originalCameraTarget;
bool newCameraNeeded;
int encounterThreshold;
float radius;
float cameraAngle = 90.0f;
float deltaTime;
float neededDegree;
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
Model[] cubeModels;

/* battle related things */
struct EnemyCube {
    Vector3 position;
    string name;
    int health = 20;
    Model model;
}
Model floorModel;
bool loadedShader;

struct BattleState {
    int playerTurns;
    int enemyTurns;
    bool playerTurn; // true if it's the player's turn, false for enemies
}
Cube[] battleCubes;
BattleState battleState;
bool battleDialog;
EnemyCube[] enemyCubes; // Массив для хранения вражеских кубов
int selectedEnemyIndex = 0; // Индекс выбранного вражеского куба
bool selectingEnemy = false; // Флаг выбора вражеского куба
bool inBattle = false;
bool isBossfight;
int retreated;
float runMessageTimer = 0.0f;
bool showRunMessage = false;
bool showRetreatedMessage = false;
float retreatedMessageTimer = 0.0f;
string retreatMessage; // To hold the retreat messag
int selectedTabIndex = 0;
int secInBattle = false;
int playerMana = 30;

/* lua things */
lua_State* L;

/* interface things */
float flicker = 0.0;
bool increasing = true;
int ver = 1;
bool showInventory = false;
bool showMapPrompt = false;
bool showDebug = false;
bool audioEnabled;
int gamepadInt = 0;

/* dialogs */
bool allowControl = true; //for checking is control allowed at this moment
bool showDialog = false; //is dialog must be shown now
bool allow_exit_dialog = true; //can you exit from dialog
int selectedChoice = 0;
int pageChoice_glob;
int answer_num;
string name = "Sasha";
bool isTextFullyDisplayed;
int emotion_global;
string name_global;
string[] message_global;
bool show_sec_dialog = false;
static int currentChoiceCharIndex = 0;
bool event_initialized;
string[] choices; // To hold choices from Lua
Font fontdialog;
// Constants for dialog display
enum int FONT_SIZE = 40;
enum float PADDING_RATIO = 1.0 / 9.0;
enum int CHAR_RECT_HEIGHT_RATIO = 5;
enum int CHAR_RECT_WIDTH_RATIO = 7;
float typingSpeed;

/* inventory */
string[][] buttonTexts = [
    ["Physical attack", "Gun attack", "Pass"], // Для вкладки "Attack"
    ["Agi 4MP", "Bufu 4MP", "Zio 3MP", "Dia 6MP"],  // Для вкладки "Magic"
    ["Medicine", "Dis-stun", "Dis-poison", "Revival bead"],
    ["Seduce", "Pester", "Default"],
    ["Rethreat"]
];
string[][] buttonTextsInventory = [
    ["Rasputin"], // Для вкладки "Summon"
    ["Rasputin"],  // Для вкладки "Return"
    ["Agi 4MP", "Bufu 4MP", "Zio 3MP", "Dia 6MP"],  // Для вкладки "Magic"
    ["Revival Bead"], // item
    ["Save", "Exit game"] // system
];
string[3] myDemons;
int selectedButtonIndex = 0;
int selectedSubmenuButtonIndex = 0;

/* audio things */
Music music;
char* musicpath;
Music musicBattle;

/* controls */
struct ControlConfig {
    immutable char right_button;
    immutable char left_button;
    immutable char back_button;
    immutable char forward_button;
    immutable char dialog_button;
    immutable char opmenu_button;
}

/* main menu */
bool debugBuild = false;
int playerHealth = 120;
enum GameState {
    MainMenu,
    InGame,
    Options,
    Exit
}
GameState currentGameState = GameState.MainMenu;
bool videoFinished;
bool rel = false;

/* lighting */
Light[4] lights;

/* models and locations */
float modelLocationSize;
string location_name;
bool friendlyZone;
float modelCharacterSize;
float modelCubeSize;
int FPS = 60;
Shader shader;
bool isNewLocationNeeded = false;
float rotationCube;
bool needRotationCube;
bool shaderEnabled = true;
char* fsdata; // Use dynamic arrays instead of char*
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

