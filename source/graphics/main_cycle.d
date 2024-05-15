//quantumde1 developed software, licensed under BSD-0-Clause license.
module graphics.main_cycle;

import raylib;
import bindbc.lua;

import std.stdio;
import std.math;
import std.file;
import std.string;
import std.conv;

import std.typecons;

import script;
import dialogs.dialog_system;
import ui.navigator;
int ver = 1;
import scripts.lua_engine;
import graphics.cubes;
//global vars for code
bool allowControl = true; //for checking is control allowed at this moment
bool showDialog = false; //is dialog must be shown now
bool allow_exit_dialog = true; //can you exit from dialog
Cube[] cubes; //massive of cubes
Nullable!Cube trackingCube; //check is we tracking any cube
bool isCubeMoving = false; //is any cube moving(except player)
float desiredDistance = 10.0f;//i forgot what it doing

/* Initializing controls */
struct ControlConfig {
    immutable char right_button;
    immutable char left_button;
    immutable char back_button;
    immutable char forward_button;
    immutable char dialog_button;
}

/* parse_conf defined in scripts/script.d */
ControlConfig loadControlConfig() {
    immutable char right_button = parse_conf("conf/layout.conf", "right");
    immutable char left_button = parse_conf("conf/layout.conf", "left");
    immutable char back_button = parse_conf("conf/layout.conf", "backward");
    immutable char forward_button = parse_conf("conf/layout.conf", "forward");
    immutable char dialog_button = parse_conf("conf/layout.conf", "dialog");
    return ControlConfig(right_button, left_button, back_button, forward_button, dialog_button);
}
//closing audio
void closeAudio() {
    UnloadMusicStream(music);
    CloseAudioDevice();
}
//initializing window and camera
void initWindowAndCamera(string window_name, int screenWidth, int screenHeight, ref Camera3D camera) {
    //init window and if window is closing write error
    InitWindow(screenWidth, screenHeight, toStringz(window_name));
    if (WindowShouldClose()) {
        writeln("window init error");
        return;
    }
    //setting up camera
    camera.position = Vector3(0.0f, 12.0f, 10.0f);
    camera.target = Vector3(0.0f, 0.0f, 0.0f);
    camera.up = Vector3(0.0f, 1.0f, 0.0f); 
    camera.fovy = 45.0f;                                
    camera.projection = CameraProjection.CAMERA_PERSPECTIVE;             
}

//update camera and cube position sequentially
void updateCameraAndCubePosition(ref Camera3D camera, ref Vector3 cubePosition, float cameraSpeed, float deltaTime, 
char fwd, char bkd, char lft, char rgt, bool allowControl) {
    //setting camera position for cube view
    Vector3 forward = Vector3Subtract(camera.target, camera.position);
    forward.y = 0;
    forward = Vector3Normalize(forward);
    Vector3 right = Vector3CrossProduct(forward, camera.up);
    right = Vector3Normalize(right);
    //setting speed up with right shift
    float speedMultiplier = IsKeyDown(KeyboardKey.KEY_RIGHT_SHIFT) ? 2.0f : 1.0f;

    Vector3 movement;
    // checking pressed buttons and moving accordingly
    if (allowControl && !isCubeMoving) {
        if (IsKeyDown(fwd)) {
            movement = Vector3Scale(forward, cameraSpeed * deltaTime * speedMultiplier);
            camera.position = Vector3Add(camera.position, movement);
            camera.target = Vector3Add(camera.target, movement);
            cubePosition = Vector3Add(cubePosition, movement);
        }
        if (IsKeyDown(bkd)) {
            movement = Vector3Scale(forward, cameraSpeed * deltaTime * speedMultiplier);
            camera.position = Vector3Subtract(camera.position, movement);
            camera.target = Vector3Subtract(camera.target, movement);
            cubePosition = Vector3Subtract(cubePosition, movement);
        }
        if (IsKeyDown(lft)) {
            movement = Vector3Scale(right, cameraSpeed * deltaTime);
            camera.position = Vector3Subtract(camera.position, movement);
            camera.target = Vector3Subtract(camera.target, movement);
            cubePosition = Vector3Subtract(cubePosition, movement);
        }
        if (IsKeyDown(rgt)) {
            movement = Vector3Scale(right, cameraSpeed * deltaTime);
            camera.position = Vector3Add(camera.position, movement);
            camera.target = Vector3Add(camera.target, movement);
            cubePosition = Vector3Add(cubePosition, movement);
        }
        //if there is no cubes, so what we must to do?
        if (cubes.length < 0) {
            writeln("error");
        }
        //what a fuck? idk for what i wrote it, seems like for checking collision of main cubes with other
        if (!trackingCube.isNull) {
            Vector3 targetPosition = trackingCube.get.boundingBox.min + (trackingCube.get.boundingBox.max -
            trackingCube.get.boundingBox.min) / 2.0f;
            Vector3 direction = Vector3Subtract(targetPosition, camera.position);
            direction = Vector3Normalize(direction);

            camera.target = Vector3Lerp(camera.target, targetPosition, deltaTime * cameraSpeed);
            Vector3 desiredPosition = Vector3Subtract(camera.target, Vector3Scale(direction, desiredDistance));
            camera.position = Vector3Lerp(camera.position, desiredPosition, deltaTime * cameraSpeed);
    }
    }
}

//function for displaying dialogs
void displayDialogs(Nullable!Cube collidedCube, char dlg, ref bool allowControl, ref bool showDialog, 
ref bool allow_exit_dialog, ref string name) {
    bool isCubeNotNull = !collidedCube.isNull;
    //check is cube collision is not null
    if (isCubeNotNull) {
        if (showDialog == false && allow_exit_dialog == true) {
            int fontSize = 20;
            int posY = GetScreenHeight() - fontSize - 40;
            DrawText(cast(char*)("Press "~dlg~" for dialog"), 40, posY, fontSize, Colors.BLACK);
        }
        //if all correct, show dialog from script with all needed text, name, emotion etc
        if (IsKeyPressed(dlg)) {
            if (allow_exit_dialog == true) {
                allow_exit_dialog = false;
                allowControl = false;
                name = collidedCube.get.name;
                showDialog = true;
            }
        }
    }
    //if dialog is not ended(not all text pages showed), show up "Press enter for continue" for showing next page of text
    if (showDialog && isCubeNotNull) {
        int posY = GetScreenHeight() - 20 - 40;
        display_dialog(collidedCube.get.name, collidedCube.get.emotion, collidedCube.get.text);
        DrawText(cast(char*)("Press enter for continue"), 40, posY, 20, Colors.BLACK);
    }
}

void rotateCamera(ref Camera3D camera, ref Vector3 cubePosition, ref float cameraAngle, float rotationStep, 
float radius) {
    //if left or right pressed, we rotate camera
    if (IsKeyPressed(KeyboardKey.KEY_LEFT) && allowControl == true) {
        cameraAngle -= rotationStep;
        if (cameraAngle < 0.0f) {
            cameraAngle += 360.0f;
        }
    } else if (IsKeyPressed(KeyboardKey.KEY_RIGHT) && allowControl == true) {
        cameraAngle += rotationStep;
        if (cameraAngle >= 360.0f) {
            cameraAngle -= 360.0f;
        }
    }
    //changing camera coordinates as needed
    float cameraX = cubePosition.x + radius * cos(cameraAngle * std.math.constants.PI / 180.0f);
    float cameraZ = cubePosition.z + radius * sin(cameraAngle * std.math.constants.PI / 180.0f);
    camera.position = Vector3(cameraX, camera.position.y, cameraZ);
}

void drawScene(Camera3D camera, Vector3 cubePosition, float cameraAngle, Cube[] cubes) {
    BeginMode3D(camera);
    //setting cube size, immutable for optimizations
    immutable int CubeSize = 2;
    //drawing all available cubes from massive
    foreach (cube; cubes) {
        DrawCube(cube.boundingBox.min, CubeSize, CubeSize, CubeSize, Colors.ORANGE);
        DrawCubeWires(cube.boundingBox.min, 2.0f, 2.0f, 2.0f, Colors.ORANGE);
    }
    //draw player cube
    DrawCube(cubePosition, CubeSize, CubeSize, CubeSize, Colors.GREEN);
    DrawCubeWires(cubePosition, 2.0f, 2.0f, 2.0f, Colors.GREEN);
    //draw debug grid
    DrawGrid(40, 1.0f);
    EndMode3D();
    draw_navigation(cameraAngle);
}

//checking collision function
Nullable!Cube handleCollisions(Vector3 cubePosition, Cube[] cubes, ref BoundingBox cubeBoundingBox) {
    //set object coolision
    cubeBoundingBox.min = cubePosition;
    cubeBoundingBox.max = Vector3Add(cubePosition, Vector3(2.0f, 2.0f, 2.0f));
    Nullable!Cube collidedCube;
    //checking is any cube collided with mc cube
    foreach (cube; cubes) {
        if (CheckCollisionBoxes(cubeBoundingBox, cube.boundingBox)) {
            collidedCube = cube;
            break;
        }
    }
    //return which cube is collided if there is any
    return collidedCube;
}
//main function
void engine_loader(string window_name, int screenWidth, int screenHeight) {
    Camera3D camera;
    initWindowAndCamera(window_name, screenWidth, screenHeight, camera); //init camera, window
    immutable ControlConfig controlConfig = loadControlConfig(); //loading control
    InitAudioDevice(); //init audio
    Vector3 cubePosition = { 0.0f, 0.0f, 0.0f }; //setting mc cube position
    float cameraSpeed = 5.0f; //setting camera speed so it will move as a cube
    float cameraAngle = 90.0f; //camera angle from y coor
    float rotationStep = 45.0f; //how camera will rotate
    float radius = Vector3Distance(camera.position, camera.target); //distance between camera and cube
    SetTargetFPS(60);
    BoundingBox cubeBoundingBox; //set cube coolision
    string name;
    version(Windows) {
        loadLua("libs/lua54.dll");
    }
    lua_loader(); //load scripts parser
    //main loop
    while (!WindowShouldClose()) {
        UpdateMusicStream(music);
        float deltaTime = GetFrameTime();
        updateCameraAndCubePosition(camera, cubePosition, cameraSpeed, deltaTime, controlConfig.forward_button,
        controlConfig.back_button, controlConfig.left_button, controlConfig.right_button, allowControl);
        rotateCamera(camera, cubePosition, cameraAngle, rotationStep, radius);
        Nullable!Cube collidedCube = handleCollisions(cubePosition, cubes, cubeBoundingBox);
        BeginDrawing();
        ClearBackground(Colors.RAYWHITE);
        drawScene(camera, cubePosition, cameraAngle, cubes);
        displayDialogs(collidedCube, controlConfig.dialog_button, allowControl, showDialog, allow_exit_dialog, name);
        //update position if any cube moving(except player)
        foreach (ref cube; cubes) {
            if (cube.isMoving) {
                float elapsedTime = GetTime() - cube.moveStartTime;
                if (elapsedTime >= cube.moveDuration) {
                    cube.boundingBox.min = cube.endPosition;
                    cube.isMoving = false;
                    beginNextMove(cube);
                } else {
                    float t = elapsedTime / cube.moveDuration;
                    cube.boundingBox.min = Vector3Lerp(cube.startPosition, cube.endPosition, t);
                    cube.boundingBox.max = Vector3Add(cube.boundingBox.min, Vector3(2.0f, 2.0f, 2.0f));
                }
            }
        }

        EndDrawing();
    }
    scope(exit) closeAudio();
}