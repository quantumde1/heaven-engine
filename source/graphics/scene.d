module graphics.scene;

import raylib;
import graphics.main_loop;
import std.typecons;
import graphics.cubes;
import std.string;
import std.stdio;
import std.math;
import ui.navigator;
import variables;
import std.path : dirName, buildNormalizedPath;
import std.file;
import ui.battle_ui;
import std.random;
import std.datetime;
import std.conv;

// Initializing window and camera
void initWindowAndCamera(string windowName, int screenWidth, int screenHeight, ref Camera3D camera) {
    if (WindowShouldClose()) {
        writeln("Window initialization error");
        return;
    }
    // Setting up camera
    camera = Camera3D(Vector3(0.0f, 10.0f, 10.0f), // position
                      Vector3(0.0f, 4.0f, 0.0f),  // target
                      Vector3(0.0f, 1.0f, 0.0f),  // up
                      45.0f,                       // fovy
                      CameraProjection.CAMERA_PERSPECTIVE); // projection
}

void updateCameraAndCubePosition(ref Camera3D camera, ref Vector3 cubePosition, float cameraSpeed, float deltaTime,
                                 char fwd, char bkd, char lft, char rgt, bool allowControl) {
    if (!allowControl || isCubeMoving) return;

    Vector3 forward = Vector3Subtract(camera.target, camera.position);
    forward.y = 0;
    Vector3 right = Vector3CrossProduct(forward, camera.up);

    // Normalize vectors once to avoid doing it in every frame
    forward = Vector3Normalize(forward);
    right = Vector3Normalize(right);

    // Calculate speed multiplier once
    float currentSpeedMultiplier = IsKeyDown(KeyboardKey.KEY_RIGHT_SHIFT) ? SpeedMultiplier : 3.0f;

    // Combine movement vectors based on key presses or gamepad axis
    Vector3 movement = Vector3(0, 0, 0);
    if (IsKeyDown(fwd) || GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_LEFT_Y) < -0.3) movement = Vector3Add(movement, forward);
    if (IsKeyDown(bkd) || GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_LEFT_Y) > 0.3) movement = Vector3Subtract(movement, forward);
    if (IsKeyDown(lft) || GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_LEFT_X) < -0.3) movement = Vector3Subtract(movement, right);
    if (IsKeyDown(rgt) || GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_LEFT_X) > 0.3) movement = Vector3Add(movement, right);

    // Apply movement
    if (!Vector3Equals(movement, Vector3Zero())) {
        movement = Vector3Scale(movement, cameraSpeed * deltaTime * currentSpeedMultiplier);
        camera.position = Vector3Add(camera.position, movement);
        camera.target = Vector3Add(camera.target, movement);
        cubePosition = Vector3Add(cubePosition, movement);
        if (!friendlyZone) {
            playerStepCounter++;
        }
    }

    // Check collision of main cubes with other
    if (!trackingCube.isNull) {
        Vector3 targetPosition = trackingCube.get.boundingBox.min + 
            (trackingCube.get.boundingBox.max - trackingCube.get.boundingBox.min) / 2.0f;
        Vector3 direction = Vector3Normalize(Vector3Subtract(targetPosition, camera.position));

        camera.target = Vector3Lerp(camera.target, targetPosition, deltaTime * cameraSpeed);
        Vector3 desiredPosition = Vector3Subtract(camera.target, Vector3Scale(direction, desiredDistance));
        camera.position = Vector3Lerp(camera.position, desiredPosition, deltaTime * cameraSpeed);
    }
}

void rotateScriptCamera(ref Camera3D camera, ref Vector3 cubePosition, ref float cameraAngle, float targetAngle,
                         float rotationSpeed, float radius, float deltaTime) {
    if (!isCameraRotating) {
        return;
    }
    float angleDifference = targetAngle - cameraAngle;
    if (angleDifference > 180.0f) {
        angleDifference -= 360.0f;
    } else if (angleDifference < -180.0f) {
        angleDifference += 360.0f;
    }
    float rotationAmount = rotationSpeed * deltaTime;
    if (fabs(angleDifference) > rotationAmount) {
        if (angleDifference > 0) {
            cameraAngle += rotationAmount;
        } else {
            cameraAngle -= rotationAmount;
        }
    } else {
        cameraAngle = targetAngle;
        isCameraRotating = false; 
    }
    float cameraX = cubePosition.x + radius * cos(cameraAngle * std.math.PI / 180.0f);
    float cameraZ = cubePosition.z + radius * sin(cameraAngle * std.math.PI / 180.0f);
    camera.position = Vector3(cameraX, camera.position.y, cameraZ);
}

void rotateCamera(ref Camera3D camera, ref Vector3 cubePosition, ref float cameraAngle, float rotationStep, 
float radius) {
    // Rotate camera based on key presses or gamepad buttons
    if (allowControl) {
        if (IsKeyDown(KeyboardKey.KEY_LEFT)) {
            cameraAngle -= rotationStep;
            if (cameraAngle < 0.0f) cameraAngle += 360.0f;
        } else if (IsKeyDown(KeyboardKey.KEY_RIGHT)) {
            cameraAngle += rotationStep;
            if (cameraAngle >= 360.0f) cameraAngle -= 360.0f;
        }
        if (IsKeyPressed(KeyboardKey.KEY_Q) || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_TRIGGER_1)) {
            cameraAngle -= 45.0f;
            if (cameraAngle < 0.0f) cameraAngle += 360.0f;
        }
        if (IsKeyPressed(KeyboardKey.KEY_E) || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_TRIGGER_1)) {
            cameraAngle += 45.0f;
            if (cameraAngle >= 360.0f) cameraAngle -= 360.0f;
        }
        else if (GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_X) < -0.2) {
            cameraAngle -= rotationStep * 1.5;
            if (cameraAngle < 0.0f) cameraAngle += 360.0f;
        } else if (GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_X) > 0.2) {
            cameraAngle += rotationStep * 1.5;
            if (cameraAngle >= 360.0f) cameraAngle -= 360.0f;
        }
    }

    // Update camera position
    float cameraX = cubePosition.x + radius * cos(cameraAngle * std.math.PI / 180.0f);
    float cameraZ = cubePosition.z + radius * sin(cameraAngle * std.math.PI / 180.0f);
    camera.position = Vector3(cameraX, camera.position.y, cameraZ);
}

void drawScene(Model floorModel, Texture2D floorTexture, Camera3D camera, Vector3 cubePosition, float cameraAngle, 
                Model[] cubeModels, Model playerModel, Texture2D playerTexture) {
 
    // Apply textures
    floorModel.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = floorTexture;
    playerModel.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = playerTexture;

    // Scale factors
    float playerScale = 3.6f; // Make the player model twice as large
    float cubeScale = 3.6f; // Make other models twice as large

    BeginMode3D(camera);

    // Draw cubes as models
    foreach(cube; cubeModels) {
        foreach(i, cubeModel; cubeModels) {
            Vector3 position = cubes[i].boundingBox.min;
            DrawModel(cubeModel, position, cubeScale, Colors.WHITE);
        }
    }

    // Draw player model with rotation
    Vector3 playerPosition = cubePosition;

    // Calculate the rotation in radians based on the camera angle plus an additional fixed 45 degrees
    float additionalRotation = 270.0f * std.math.PI / 180.0f; // Convert 45 degrees to radians
    float playerRotation = (-cameraAngle * std.math.PI / 180.0f) + additionalRotation; // Convert degrees to radians and add the 45-degree offset
    Matrix rotationMatrix = MatrixRotate(Vector3(0.0f, 1.0f, 0.0f), playerRotation);

    DrawModelEx(playerModel, playerPosition, Vector3(0.0f, 1.0f, 0.0f), playerRotation * 180.0f / std.math.PI, Vector3(playerScale, playerScale, playerScale), Colors.WHITE);

    // Draw floor model
    DrawModel(floorModel, Vector3(0.0f, -1.0f, 0.0f), 40.0f, Colors.WHITE);
    
    EndMode3D();

    if (!inBattle && !friendlyZone) {
        draw_navigation(cameraAngle);
    }
}

Nullable!Cube handleCollisions(Vector3 cubePosition, Cube[] cubes, ref BoundingBox cubeBoundingBox) {
    cubeBoundingBox = BoundingBox(cubePosition, Vector3Add(cubePosition, Vector3(CubeSize, CubeSize, CubeSize)));
    foreach (cube; cubes) {
        if (CheckCollisionBoxes(cubeBoundingBox, cube.boundingBox)) {
            return Nullable!Cube(cube); // Return cube number in cube[] array
        }
    }
    return Nullable!Cube.init; // Return an empty Nullable!Cube if no collision is detected
}
