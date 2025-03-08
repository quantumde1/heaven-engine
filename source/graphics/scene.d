// quantumde1 developed software, licensed under BSD-0-Clause license.
module graphics.scene;

import raylib;
import graphics.engine;
import std.typecons;
import graphics.cubes;
import std;
import std.stdio;
import std.math;
import variables;
import std.path;
import std.file;
import std.random;
import std.datetime;
import std.conv;
import scripts.config;
import std.json;
import std.array;

// Constants
private const float TWO_PI = 2.0f * std.math.PI;
private const float FULL_ROTATION = 360.0f;
private const float HALF_ROTATION = 180.0f;

void parseSceneFile(string path) {
    JSONValue scene = parseJSON(readText(path));
    JSONValue objects = scene["objects"];
    for (int i = 0; i < objects.array.length; i++) {
        switch (objects[i]["type"].str) {
            case "model":
                model_location_path = cast(char*)toStringz(objects[i]["modelPath"].str);
                JSONValue scale = objects[i]["scale"];
                JSONValue position = objects[i]["position"];
                JSONValue rotation = objects[i]["rotation"];
                modelPosition[i] = Vector3(position["x"].get!float, position["y"].get!float, position["z"].get!float);
                modelLocationSize[i] = Vector3(scale["x"].get!float, scale["y"].get!float, scale["z"].get!float);
                modelLocationRotate[i] = Vector3(rotation["x"].get!float, rotation["y"].get!float, rotation["z"].get!float);
                rotateAngle[i] = objects[i]["rotationAngle"].get!float;
                floorModel[i] = LoadModel(model_location_path);
                
                break;
            case "light":
                JSONValue color = objects[i]["color"];
                JSONValue position = objects[i]["position"];
                break;
            default:
                break;
        }
    }
    JSONValue environment = scene["environment"];
    texture_skybox = LoadTexture(cast(char*)environment["skybox"].str);
}

// Function to initialize the camera
Camera3D createCamera() {
    // Set the field of view and projection type
    float fov = 45.0f;
    CameraProjection projection = CameraProjection.CAMERA_PERSPECTIVE;
    
    // Create and return the camera
    return Camera3D(positionCam, targetCam, upCam, fov, projection);
}

// Function to initialize the window and camera
void initWindowAndCamera(ref Camera3D camera) {
    
    
    // Initialize the camera
    camera = createCamera();
}

float playerModelRotation = 180;
bool isMoving = false;

void controlFunction(ref Camera3D camera, ref Vector3 cubePosition,
char fwd, char bkd, char lft, char rgt, bool allowControl, float deltaTime, float cameraSpeed) {
    if (!allowControl || isCubeMoving) return;
    Vector3 forward = Vector3Normalize(Vector3Subtract(camera.target, camera.position));
    forward.y = 0;
    Vector3 right = Vector3Normalize(Vector3CrossProduct(forward, camera.up));
    
    Vector3 movement = Vector3(0, 0, 0);
    bool isMovingForward = IsKeyDown(fwd) || GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_Y) < -0.3 || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP);
    bool isMovingBackward = IsKeyDown(bkd) || GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_Y) > 0.3 || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN);
    bool isMovingLeft = IsKeyDown(lft) || GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_X) < -0.3 || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT);
    bool isMovingRight = IsKeyDown(rgt) || GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_X) > 0.3 || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT);

    // Вычисление угла поворота на основе комбинаций клавиш
    if (isMovingForward && isMovingLeft) {
        playerModelRotation = 45.0f; // 45 градусов влево от направления вперед
    } else if (isMovingForward && isMovingRight) {
        playerModelRotation = 315.0f; // 45 градусов вправо от направления вперед
    } else if (isMovingBackward && isMovingLeft) {
        playerModelRotation = 135.0f; // 45 градусов влево от направления назад
    } else if (isMovingBackward && isMovingRight) {
        playerModelRotation = 225.0f; // 45 градусов вправо от направления назад
    } else if (isMovingForward) {
        playerModelRotation = 0.0f; // Вперед
    } else if (isMovingBackward) {
        playerModelRotation = 180.0f; // Назад
    } else if (isMovingLeft) {
        playerModelRotation = 90.0f; // Влево
    } else if (isMovingRight) {
        playerModelRotation = 270.0f; // Вправо
    } else {
        isMoving = false;
    }

    // Обновление движения
    if (isMovingForward) {
        isMoving = true;
        movement += forward;
    }
    if (isMovingBackward) {
        isMoving = true;
        movement -= forward;
    }
    if (isMovingLeft) {
        isMoving = true;
        movement -= right;
    }
    if (isMovingRight) {
        isMoving = true;
        movement += right;
    }

    if ((IsKeyDown(KeyboardKey.KEY_LEFT_SHIFT) || 
    IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_LEFT)) && isMoving == true) {
        float startTime = GetFrameTime();
        if (stamina <= 10.0f) {
            debug_writeln("Stamina below 10. Slowing.");
            movement *= 1.07f;
            stamina -= startTime * 2;
        } else {
            movement *= 1.7f;
        }
        stamina -= startTime * 4;
    }
    if (!Vector3Equals(movement, Vector3Zero())) {
        if (dungeonCrawlerMode) {
            movement = Vector3Normalize(movement);
            movement = Vector3Scale(movement, 0.5f);
        } else {
            movement = Vector3Scale(movement, cameraSpeed * deltaTime * 3.0f);
        }

        camera.position += movement;
        camera.target += movement;
        cubePosition += movement;
        if (!friendlyZone) playerStepCounter++;
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

void rotateCamera(ref Camera3D camera, ref Vector3 cubePosition, ref float cameraAngle, 
                  float rotationStep, float radius) {
    if (allowControl) {
        float targetAngle;
        if (!dungeonCrawlerMode) {
            // Обработка ввода от правого стика
            float rightStickX = GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_RIGHT_X);
            if (fabs(rightStickX) > 0.3) {
                cameraAngle = fmod(cameraAngle + rotationStep * rightStickX, 360.0f);
                if (cameraAngle < 0) cameraAngle += 360.0f;
            }

            // Обработка ввода от клавиш и триггеров
            if (IsKeyDown(KeyboardKey.KEY_RIGHT)
            || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_TRIGGER_1)) {
                cameraAngle = fmod(cameraAngle + rotationStep, 360.0f);
                if (cameraAngle < 0) cameraAngle += 360.0f;
            }
            if (IsKeyDown(KeyboardKey.KEY_LEFT)
            || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_TRIGGER_1)) {
                cameraAngle = fmod(cameraAngle - rotationStep, 360.0f);
                if (cameraAngle < 0) cameraAngle += 360.0f;
            }
        } else {
            targetAngle = 90.0f;
            if (IsKeyPressed(KeyboardKey.KEY_LEFT)
            || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_TRIGGER_1)) {
                cameraAngle = fmod(cameraAngle - targetAngle, 360.0f);
                if (cameraAngle < 0) cameraAngle += 360.0f;
            }
            if (IsKeyPressed(KeyboardKey.KEY_RIGHT)
            || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_TRIGGER_1)) {
                cameraAngle = fmod(cameraAngle + targetAngle, 360.0f);
                if (cameraAngle < 0) cameraAngle += 360.0f;
            }
        }
    }

    // Обновление позиции камеры
    float cameraX = cubePosition.x + radius * cos(cameraAngle * std.math.PI / 180.0f);
    float cameraZ = cubePosition.z + radius * sin(cameraAngle * std.math.PI / 180.0f);
    camera.position = Vector3(cameraX, camera.position.y, cameraZ);
}


float plrttn = 135.0f;

void drawScene(Model[] floorModel, Camera3D camera, Vector3 cubePosition, float cameraAngle, 
                Model[] cubeModels, Model playerModel) {
    float[3] cameraPos = [camera.position.x, camera.position.y, camera.position.z];
    SetShaderValue(shader, shader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW], &cameraPos[0],
    ShaderUniformDataType.SHADER_UNIFORM_VEC3);

    float playerScale = modelCharacterSize;
    BeginMode3D(camera);
    // Draw cubes as models
    foreach (i, cubeModel; cubeModels) {
        Vector3 position = cubes[i].boundingBox.min;
        DrawModelEx(cubeModel, position, Vector3(0.0f, 1.0f, 0.0f), cubes[i].rotation, Vector3(modelCubeSize, modelCubeSize, modelCubeSize), Colors.WHITE);
    }

    // Draw player model with rotation
    Vector3 playerPosition = cubePosition;
    float additionalRotation = 270.0f * std.math.PI / 180.0f; 
    float playerRotation;
    if (isMoving == true) {
        playerRotation = (-cameraAngle * std.math.PI / 180.0f) + additionalRotation + playerModelRotation * std.math.PI / 180.0f;
        plrttn = playerRotation;
    } else {
        playerRotation = plrttn;
    }
    if (drawPlayer == true) {
        DrawModelEx(playerModel, playerPosition, Vector3(0.0f, 1.0f, 0.0f), playerRotation * 180.0f / std.math.PI, 
        Vector3(playerScale, playerScale, playerScale), Colors.WHITE);
    }
    // Draw floor model
    for (int i = 0; i < floorModel.length; i++) {
        DrawModelEx(floorModel[i], modelPosition[i], modelLocationRotate[i], rotateAngle[i], modelLocationSize[i], Colors.WHITE);
    }
    EndMode3D();
}