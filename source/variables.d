module variables;
import graphics.cubes;
import std.typecons;
import raylib;

extern (C) char* get_file_data_from_archive(const char *input_file, const char *file_name, uint *file_size_out);

struct EnemyCube {
    Vector3 position;
    string name;
    int health = 20;
    Model model;
}
struct BattleState {
    int playerTurns;
    int enemyTurns;
    bool playerTurn; // true if it's the player's turn, false for enemies
}
Vector3 cubePosition = { 0.0f, 0.0f, 0.0f };
float radius;
Camera3D camera;
BattleState battleState;
float cameraAngle = 90.0f;
EnemyCube[] enemyCubes; // Массив для хранения вражеских кубов
int selectedEnemyIndex = 0; // Индекс выбранного вражеского куба
bool selectingEnemy = false; // Флаг выбора вражеского куба
float flicker = 0.0;
bool increasing = true;
int ver = 1;
bool showInventory  =false;
//global vars for code
bool allowControl = true; //for checking is control allowed at this moment
bool showDialog = false; //is dialog must be shown now
bool allow_exit_dialog = true; //can you exit from dialog
Cube[] cubes; //massive of cubes
Nullable!Cube trackingCube; //check is we tracking any cube
bool isCubeMoving = false; //is any cube moving(except player)
float desiredDistance = 10.0f;//i forgot what it doing
int playerStepCounter = 0;
bool inBattle = false;
Music music;
Vector3 originalCubePosition;
Vector3 originalCameraPosition;
Vector3 originalCameraTarget;
enum CubeSize = 2;
enum SpeedMultiplier = 2.0f;
import raylib_lights;
// Двумерный массив текста кнопок для каждой вкладки
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
    ["Dia 6MP", "Agi 4MP", "Bufu 4MP"], // skill
    ["Revival Bead"], // item
    ["Save", "Exit game"] // system
];
string[10] availableItems;
string[12] inventory;
string[5] myDemons;
string name = "Sasha";
int selectedButtonIndex = 0;
int selectedSubmenuButtonIndex = 0;
struct ControlConfig {
    immutable char right_button;
    immutable char left_button;
    immutable char back_button;
    immutable char forward_button;
    immutable char dialog_button;
}
Cube[] battleCubes;
bool debugBuild = false;
int selectedTabIndex = 0;
int secInBattle = false;
int playerHealth = 120;
enum GameState {
    MainMenu,
    InGame,
    Options,
    Exit
}
GameState currentGameState = GameState.MainMenu;
bool videoFinished;
bool showMapPrompt = false;
bool showDebug = false;
bool rel = false;
int emotion_global;
string name_global;
string[] message_global;
bool show_sec_dialog = false;
char* model_location_path;
char* texture_model_location_path;
bool event_initialized;
string location_name;
bool friendlyZone;
float deltaTime;
float neededDegree;
float iShowSpeed;
float oldSpeed;
float oldDegree;
bool isCameraRotating = true;
int selectedChoice = 0;
int pageChoice_glob;
int answer_num;
char* musicpath;
Shader shader;
bool isNewLocationNeeded = false;
Light[4] lights;
float modelLocationSize;
float modelCharacterSize;
