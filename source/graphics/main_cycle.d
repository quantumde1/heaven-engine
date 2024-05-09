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

bool allowControl = true;
bool showDialog = false;
bool allow_exit_dialog = true;

void engine_loader(string window_name, int screenWidth, int screenHeight)
{
        //setting layout
    char rgt = parse_conf("conf/layout.conf", "right");
    char lft = parse_conf("conf/layout.conf", "left");
    char bkd = parse_conf("conf/layout.conf", "backward");
    char fwd = parse_conf("conf/layout.conf", "forward");
    char dlg = parse_conf("conf/layout.conf", "dialog");

    string name;
    InitAudioDevice();
    Vector3 forward;
    Vector3 right;
    writeln("loading raylib 5.0.1, heaven engine ", ver);
    //init window & camera, settings variables
    InitWindow(screenWidth, screenHeight, cast(char*)window_name);
    Camera3D camera;
    float cameraSpeed = 5.0f;
    camera.position = Vector3(0.0f, 12.0f, 10.0f);
    camera.target = Vector3(0.0f, 0.0f, 0.0f);
    camera.up = Vector3(0.0f, 1.0f, 0.0f); 
    camera.fovy = 45.0f;                                
    camera.projection = CameraProjection.CAMERA_PERSPECTIVE;             
    Vector3 cubePosition = { 0.0f, 0.0f, 0.0f };
    float radius = Vector3Distance(camera.position, camera.target);
    float cameraAngle = 90.0f;
    float rotationStep = 45.0f;
    SetTargetFPS(60);
    BoundingBox cubeBoundingBox = {cubePosition, Vector3Add(cubePosition, Vector3(2.0f, 2.0f, 2.0f))};
    // Main game loop(moving,script)
    LuaSupport ret = loadLua();
    lua_loader();
    while (!WindowShouldClose())
    {
        UpdateMusicStream(music);
        forward = Vector3Subtract(camera.target, camera.position);
        forward.y = 0;
        forward = Vector3Normalize(forward);
        right = Vector3CrossProduct(forward, camera.up);
        right = Vector3Normalize(right);
        float deltaTime = GetFrameTime();
        if (IsKeyDown(fwd) && allowControl == true) {
            camera.position = Vector3Add(camera.position, Vector3Scale(forward, cameraSpeed * deltaTime));
            camera.target = Vector3Add(camera.target, Vector3Scale(forward, cameraSpeed * deltaTime));
            cubePosition = Vector3Add(cubePosition, Vector3Scale(forward, cameraSpeed * deltaTime));
        } else if (IsKeyDown(bkd) && allowControl == true) {
            camera.position = Vector3Subtract(camera.position, Vector3Scale(forward, cameraSpeed * deltaTime));
            camera.target = Vector3Subtract(camera.target, Vector3Scale(forward, cameraSpeed * deltaTime));
            cubePosition = Vector3Subtract(cubePosition, Vector3Scale(forward, cameraSpeed * deltaTime));
        }
        if (IsKeyDown(lft) && allowControl == true) {
            camera.position = Vector3Subtract(camera.position, Vector3Scale(right, cameraSpeed * deltaTime));
            camera.target = Vector3Subtract(camera.target, Vector3Scale(right, cameraSpeed * deltaTime));
            cubePosition = Vector3Subtract(cubePosition, Vector3Scale(right, cameraSpeed * deltaTime));
        } else if (IsKeyDown(rgt) && allowControl == true) {
            camera.position = Vector3Add(camera.position, Vector3Scale(right, cameraSpeed * deltaTime));
            camera.target = Vector3Add(camera.target, Vector3Scale(right, cameraSpeed * deltaTime));
            cubePosition = Vector3Add(cubePosition, Vector3Scale(right, cameraSpeed * deltaTime));
        } else if (IsKeyPressed(KeyboardKey.KEY_LEFT) && allowControl == true) {
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
        float cameraX = cubePosition.x + radius * cos(cameraAngle * std.math.constants.PI / 180.0f);
        float cameraZ = cubePosition.z + radius * sin(cameraAngle * std.math.constants.PI / 180.0f);
        camera.position = Vector3(cameraX, camera.position.y, cameraZ);
        BeginDrawing();
        ClearBackground(Colors.RAYWHITE);
        cubeBoundingBox.min = cubePosition;
        cubeBoundingBox.max = Vector3Add(cubePosition, Vector3(2.0f, 2.0f, 2.0f));
        Nullable!Cube collidedCube;

        foreach (cube; cubes) {
            if (CheckCollisionBoxes(cubeBoundingBox, cube.boundingBox)) {
                collidedCube = cube;
                break;
            }
        }
        if (!collidedCube.isNull) {
            if (showDialog == false && allow_exit_dialog == true) {
                int fontSize = 20;
                int posY = GetScreenHeight() - fontSize - 40;
                DrawText(cast(char*)("Press "~dlg~" for dialog"), 40, posY, fontSize, Colors.BLACK);
            }
            if (IsKeyPressed(dlg)) {
                if (allow_exit_dialog == true) {
                    allow_exit_dialog = false;
                    allowControl = false;
                    name = collidedCube.get.name;
                    showDialog = true;
                }
            }
        }
        BeginMode3D(camera);   
        foreach (cube; cubes) {
            DrawCube(cube.boundingBox.min, 2.0f, 2.0f, 2.0f, Colors.ORANGE);
            DrawCubeWires(cube.boundingBox.min, 2.0f, 2.0f, 2.0f, Colors.ORANGE);
        }
        DrawCube(cubePosition, 2.0f, 2.0f, 2.0f, Colors.GREEN);
        DrawCubeWires(cubePosition, 2.0f, 2.0f, 2.0f, Colors.GREEN);
        DrawGrid(40, 1.0f);
        EndMode3D();
        draw_navigation(cameraAngle);
        if (showDialog && !collidedCube.isNull) {
            int posY = GetScreenHeight() - 20 - 40;
            display_dialog(collidedCube.get.name, collidedCube.get.emotion, collidedCube.get.text);
            DrawText(cast(char*)("Press enter for continue"), 40, posY, 20, Colors.BLACK);
        }
        EndDrawing();
    }
    UnloadMusicStream(music);
    CloseAudioDevice();  
    CloseWindow();
}