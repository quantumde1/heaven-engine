module scene.loader;

import std.stdio;
import std.math;

import raylib;

import scene.objects;

class Scene {
    Camera3D camera;
    Vector3 playerPosition;

    float cameraAngle = 90;
    float rotationStep = 1;
    float radius = 10;
    
    this(Camera3D camera, Vector3 playerPosition) {
        this.camera = camera;
        this.playerPosition = playerPosition;
    }

    void rotateCamera(Vector3 playerPosition) {
        if (IsKeyDown(KeyboardKey.KEY_RIGHT)) {
            cameraAngle = fmod(cameraAngle + rotationStep, 360.0f);
            if (cameraAngle < 0) cameraAngle += 360.0f;
        }
        if (IsKeyDown(KeyboardKey.KEY_LEFT)) {
            cameraAngle = fmod(cameraAngle - rotationStep, 360.0f);
            if (cameraAngle < 0) cameraAngle += 360.0f;
        }

        float cameraX = playerPosition.x + radius * cos(cameraAngle * std.math.PI / 180.0f);
        float cameraZ = playerPosition.z + radius * sin(cameraAngle * std.math.PI / 180.0f);
        camera.position = Vector3(cameraX, camera.position.y, cameraZ);
    }
    float getCameraAngle() {
        return cameraAngle;
    }
}

class NPC {

}