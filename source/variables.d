module variables;

import graphics.cubes;
import std.typecons;
import raylib;
import bindbc.lua;
import raylib_lights;

extern (C) char* get_file_data_from_archive(const char *input_file, const char *file_name, uint *file_size_out);

ControlConfig controlConfig;

const int PLAYER_HEALTH_BAR_X = 10;
const float CUBE_DRAW_HEIGHT = 2.5f;
const float PLAYER_HEALTH_BAR_WIDTH = 200.0f;
const float PLAYER_HEALTH_BAR_HEIGHT = 20.0f;
const int PLAYER_HEALTH_BAR_Y_OFFSET = 10;
const int ATTACK_DAMAGE = 5;
const int PLAYER_DAMAGE = 15;

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

Model[20] floorModel;
bool loadedShader;

struct BattleState {
    int playerTurns;
    int enemyTurns;
    bool playerTurn; // true if it's the player's turn, false for enemies
}

// struct
struct Enemy {
    int maxHealth;
    int currentHealth;
    Texture2D texture;
}

Enemy[] enemies;

int XP;
BattleState battleState;
bool battleDialog;
int selectedEnemyIndex = 0; // Индекс выбранного вражеского куба
bool selectingEnemy = false; // Флаг выбора вражеского куба
bool inBattle = false;
bool isBossfight;
Texture2D background;
int selectedTabIndex = 0;
int secInBattle = false;
int playerMana = 30;

/* lua things */
lua_State* L;

/* interface things */
float flicker = 0.0;
bool increasing = true;
float ver = 0.6;
bool showInventory = false;
bool showMapPrompt = false;
bool showDebug = false;
bool audioEnabled;
int gamepadInt = 0;

/* dialogs */
Texture2D texture_old;
bool allowControl = true; //for checking is control allowed at this moment
bool showDialog = false; //is dialog must be shown now
bool allow_exit_dialog = true; //can you exit from dialog
int selectedChoice = 0;
int pageChoice_glob;
int answer_num;
string name = "Sasha";
bool isTextFullyDisplayed;
bool isTextureImageLoaded;
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

struct TextureShow {
    float x;
    float y;
    Texture2D texture;
    float scale;
}

debug {
    int background_name;
}
TextureShow[5] tex2d;
Texture2D[5] backgrounds;

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
bool debugBuild = false;
int playerHealth = 120;
enum GameState {
    MainMenu,
    InGame,
    Options,
    Exit,
    LuaReload
}
GameState currentGameState = GameState.MainMenu;
bool videoFinished;

/* lighting */
Light[8] lights;

/* models and locations */
Vector3[70] modelLocationSize;
Vector3[70] modelLocationRotate;
float[70] rotateAngle;
Vector3[70] modelPosition;
string location_name;
Texture2D texture_skybox;
bool friendlyZone;
float modelCharacterSize;
Texture2D dialogImage;
Texture2D texture_background;
Texture2D texture_character;
int posY_tex_char;
int posX_tex_char;
float scaleUp_char;
bool neededDraw2D;
bool drawPlayer;
float modelCubeSize;
bool pos;
int FPS = 60;
Shader shader;
bool isNewLocationNeeded = false;
bool showCharacterNameInputMenu;
bool hideNavigation;
bool neededCharacterDrawing;
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

