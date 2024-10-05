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

// Constants
private const float TWO_PI = 2.0f * std.math.PI;
private const float FULL_ROTATION = 360.0f;
private const float HALF_ROTATION = 180.0f;

// Initializing window and camera
void initWindowAndCamera(string windowName, int screenWidth, int screenHeight, ref Camera3D camera) {
    if (WindowShouldClose()) {
        writeln("Window initialization error");
        return;
    }
    camera = Camera3D(Vector3(0.0f, 10.0f, 10.0f), Vector3(0.0f, 4.0f, 0.0f), Vector3(0.0f, 1.0f, 0.0f), 45.0f, CameraProjection.CAMERA_PERSPECTIVE);
}

void updateCameraAndCubePosition(ref Camera3D camera, ref Vector3 cubePosition, float cameraSpeed, float deltaTime,
                                 char fwd, char bkd, char lft, char rgt, bool allowControl) {
    if (!allowControl || isCubeMoving) return;

    Vector3 forward = Vector3Normalize(Vector3Subtract(camera.target, camera.position));
    forward.y = 0;
    Vector3 right = Vector3Normalize(Vector3CrossProduct(forward, camera.up));

    float currentSpeedMultiplier = IsKeyDown(KeyboardKey.KEY_RIGHT_SHIFT) ? SpeedMultiplier : 3.0f;

    Vector3 movement = Vector3(0, 0, 0);
    if (IsKeyDown(fwd) || GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_LEFT_Y) < -0.3) movement += forward;
    if (IsKeyDown(bkd) || GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_LEFT_Y) > 0.3) movement -= forward;
    if (IsKeyDown(lft) || GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_LEFT_X) < -0.3) movement -= right;
    if (IsKeyDown(rgt) || GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_LEFT_X) > 0.3) movement += right;

    if (!Vector3Equals(movement, Vector3Zero())) {
        movement = Vector3Scale(movement, cameraSpeed * deltaTime * currentSpeedMultiplier);
        camera.position += movement;
        camera.target += movement;
        cubePosition += movement;
        if (!friendlyZone) playerStepCounter++;
    }

    if (!trackingCube.isNull) {
        Vector3 targetPosition = trackingCube.get.boundingBox.min + (trackingCube.get.boundingBox.max - trackingCube.get.boundingBox.min) / 2.0f;
        Vector3 direction = Vector3Normalize(Vector3Subtract(targetPosition, camera.position));
        camera.target = Vector3Lerp(camera.target, targetPosition, deltaTime * cameraSpeed);
        camera.position = Vector3Lerp(camera.position, Vector3Subtract(camera.target, Vector3Scale(direction, desiredDistance)), deltaTime * cameraSpeed);
    }
}

void rotateScriptCamera(ref Camera3D camera, ref Vector3 cubePosition, ref float cameraAngle, float targetAngle,
                         float rotationSpeed, float radius, float deltaTime) {
    if (!isCameraRotating) return;

    float angleDifference = targetAngle - cameraAngle;
    // Normalize angle difference
    if (angleDifference > HALF_ROTATION) {
        angleDifference -= FULL_ROTATION;
    } else if (angleDifference < -HALF_ROTATION) {
        angleDifference += FULL_ROTATION;
    }

    float rotationAmount = rotationSpeed * deltaTime;
    if (fabs(angleDifference) > rotationAmount) {
        cameraAngle += (angleDifference > 0) ? rotationAmount : -rotationAmount;
    } else {
        cameraAngle = targetAngle;
        isCameraRotating = false; 
    }

    // Update camera position based on the new angle
    float cameraX = cubePosition.x + radius * cos(cameraAngle * std.math.PI / 180.0f);
    float cameraZ = cubePosition.z + radius * sin(cameraAngle * std.math.PI / 180.0f);
    camera.position = Vector3(cameraX, camera.position.y, cameraZ);
}

void rotateCamera(ref Camera3D camera, ref Vector3 cubePosition, ref float cameraAngle, float rotationStep, float radius) {
    if (allowControl) {
        if (IsKeyDown(KeyboardKey.KEY_LEFT)) {
            cameraAngle = (cameraAngle - rotationStep + FULL_ROTATION) % FULL_ROTATION;
        } else if (IsKeyDown(KeyboardKey.KEY_RIGHT)) {
            cameraAngle = (cameraAngle + rotationStep) % FULL_ROTATION;
        }
        if (IsKeyPressed(KeyboardKey.KEY_Q) || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_TRIGGER_1)) {
            cameraAngle = (cameraAngle - 45.0f + FULL_ROTATION) % FULL_ROTATION;
        }
        if (IsKeyPressed(KeyboardKey.KEY_E) || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_TRIGGER_1)) {
            cameraAngle = (cameraAngle + 45.0f) % FULL_ROTATION;
        } else {
            float rightAxisMovement = GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_X);
            if (rightAxisMovement < -0.2) {
                cameraAngle = (cameraAngle - rotationStep * 1.5f + FULL_ROTATION) % FULL_ROTATION;
            } else if (rightAxisMovement > 0.2) {
                cameraAngle = (cameraAngle + rotationStep * 1.5f) % FULL_ROTATION;
            }
        }
    }

    // Update camera position
    float cameraX = cubePosition.x + radius * cos(cameraAngle * std.math.PI / 180.0f);
    float cameraZ = cubePosition.z + radius * sin(cameraAngle * std.math.PI / 180.0f);
    camera.position = Vector3(cameraX, camera.position.y, cameraZ);
}

void drawScene(Model floorModel, Camera3D camera, Vector3 cubePosition, float cameraAngle, 
                Model[] cubeModels, Model playerModel) {
    float[3] cameraPos = [camera.position.x, camera.position.y, camera.position.z];
    SetShaderValue(shader, shader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW], &cameraPos[0], ShaderUniformDataType.SHADER_UNIFORM_VEC3);    

    float playerScale = modelCharacterSize; 
    float cubeScale = 5.0f; 

    BeginMode3D(camera);

    // Draw cubes as models
    foreach (i, cubeModel; cubeModels) {
        Vector3 position = cubes[i].boundingBox.min;
        DrawModel(cubeModel, position, cubeScale, Colors.WHITE);
    }

    // Draw player model with rotation
    Vector3 playerPosition = cubePosition;
    float additionalRotation = 270.0f * std.math.PI / 180.0f; 
    float playerRotation = (-cameraAngle * std.math.PI / 180.0f) + additionalRotation; 
    DrawModelEx(playerModel, playerPosition, Vector3(0.0f, 1.0f, 0.0f), playerRotation * 180.0f / std.math.PI, Vector3(playerScale, playerScale, playerScale), Colors.WHITE);

    // Draw floor model
    DrawModel(floorModel, Vector3(0.0f, 0.0f, 0.0f), modelLocationSize, Colors.WHITE);
    EndMode3D();

    if (!inBattle && !friendlyZone) {
        draw_navigation(cameraAngle);
    }
}

Nullable!Cube handleCollisions(Vector3 cubePosition, Cube[] cubes, ref BoundingBox cubeBoundingBox) {
        // Define the bounding box for the cube at the current position
    cubeBoundingBox = BoundingBox(cubePosition, Vector3Add(cubePosition, Vector3(CubeSize, CubeSize, CubeSize)));

    // Check for collisions with other cubes
    foreach (cube; cubes) {
        if (CheckCollisionBoxes(cubeBoundingBox, cube.boundingBox)) {
            return Nullable!Cube(cube); // Return the collided cube
        }
    }
    
    return Nullable!Cube.init; // Return an empty Nullable!Cube if no collision is detected
}