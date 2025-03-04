module engine.engine;

import std.string;
import std.stdio;
import std.conv;
import std.math;

import multimedia.playback;
import player.controls;
import player.loader;
import scene.loader;
import scene.objects;
import ui.widgets;
import readers.control_parse;

import raylib;

struct KeyAction {
    int key;
    void delegate() action;
}

class Engine {
    char[4] buttonLayout;
    ControlConfig controls;

    //screen
    int screenWidth;
    int screenHeight;
    string nameOfWindow;
    
    Scene scene;
    Camera3D camera;
    Player player;
    Object3D objects;

    this(ControlConfig controls) {
        this.controls = controls;
    }

    void configure() {
        //models
        Model playerModel = LoadModel("res/mc.glb");
        objects = new Object3D(playerModel, Vector3(10, 0, 10), Vector3(1,1,1));
        player = new Player("quantumde1", 120, 0, 1, playerModel, Vector3(0, 0, 0), Vector3(1, 1, 1));
        scene = new Scene(camera, player.coordinates);
        scene.camera.position = Vector3(0.0, 10.0, 15.0);
        scene.camera.target = Vector3(0.0, 4.0, 0.0);
        scene.camera.up = Vector3(0.0, 1.0, 0.0);
        scene.camera.projection = CameraProjection.CAMERA_PERSPECTIVE;
        scene.camera.fovy = 45.0f;
    }

    void initialize() {
        InitWindow(screenWidth, screenHeight, nameOfWindow.toStringz);
        SetTargetFPS(60);
        InitAudioDevice();
    }

    void run() {    
        immutable int forward = controls.forward.to!int;
        immutable int backward = controls.backward.to!int;
        immutable int left = controls.left.to!int;
        immutable int right = controls.right.to!int;

        KeyAction[] keyActionsPlayer = [
            {forward, () { 
                player.coordinates.z -= 0.2;
                scene.camera.position.z -= 0.2;
                scene.camera.target.z -= 0.2;
            }},
            {backward, () { 
                player.coordinates.z += 0.2;
                scene.camera.position.z += 0.2;
                scene.camera.target.z += 0.2;
            }},
            {left, () { 
                player.coordinates.x -= 0.2;
                scene.camera.position.x -= 0.2;
                scene.camera.target.x -= 0.2;
            }},
            {right, () { 
                player.coordinates.x += 0.2;
                scene.camera.position.x += 0.2;
                scene.camera.target.x += 0.2;
            }},
        ];
        while (WindowShouldClose() == false) {
            scene.rotateCamera(player.coordinates);
            foreach (keyAction; keyActionsPlayer) {
                if (IsKeyDown(keyAction.key)) {
                    keyAction.action();
                }
            }
            BeginDrawing();
            ClearBackground(Colors.WHITE);
            DrawText(player.coordinates.z.to!string.toStringz, 40, 40, 30, Colors.BLACK);
            DrawFPS(40, 80);
            BeginMode3D(scene.camera);
            DrawModel(player.model, player.coordinates, player.scale.x, Colors.WHITE);
            DrawModel(objects.model, objects.coordinates, objects.scale.x, Colors.WHITE);
            DrawGrid(20, 3);
            EndMode3D();
            EndDrawing();
        }
    }
}