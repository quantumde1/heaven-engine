module engine.engine;

import std.string;
import std.stdio;
import std.conv;

import multimedia.playback;
import player.controls;
import player.loader;
import scene.loader;
import scene.objects;
import ui.widgets;
import readers.control_parse;

import raylib;

class Engine {
    char[4] buttonLayout; //if someone here would need it, but not outside
    Player player;
    ControlConfig controls;
    int screenWidth;
    int screenHeight;
    string nameOfWindow;
    Scene scene;
    Camera3D camera;

    this(ControlConfig controls) {
        this.controls = controls;
    }

    void engineConfigurator() {
        scene = new Scene(camera);
        scene.camera.position = Vector3(0.0, 10.0, 15.0);
        scene.camera.target = Vector3(0.0, 4.0, 0.0);
        scene.camera.up = Vector3(0.0, 1.0, 0.0);
        scene.camera.projection = CameraProjection.CAMERA_PERSPECTIVE;
        scene.camera.fovy = 45.0f;
        //models
        Model playerModel = LoadModel("res/mc.glb");
        player = new Player("quantumde1", 120, 0, 1, playerModel, Vector3(0, 0, 0), Vector3(1, 1, 1));
    }

    void engineStarter() {
        InitWindow(screenWidth, screenHeight, nameOfWindow.toStringz);
        SetTargetFPS(60);
        InitAudioDevice();
    }

    void engineMain() {    
        immutable int forward = controls.forward.to!int;
        immutable int backward = controls.backward.to!int;
        immutable int left = controls.left.to!int;
        immutable int right = controls.right.to!int;
        while (WindowShouldClose() == false) {
            BeginDrawing();
            ClearBackground(Colors.WHITE);
            BeginMode3D(scene.camera);
            DrawModel(player.model, player.coordinates, player.scale.x, Colors.WHITE);
            int pressedButton = GetKeyPressed();
            switch (pressedButton) {
                case forward:
                    writeln("Pressed forward.");
                    break;
                case backward:
                    writeln("Pressed backward.");
                    break;
                case left:
                    writeln("Pressed left.");
                    break;
                case right:
                    writeln("Pressed right.");
                    break;
                default:
                    break;
            }
            EndMode3D();
            EndDrawing();
        }
    }
}