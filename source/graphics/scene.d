// quantumde1 developed software, licensed under MIT license.
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
import graphics.collision;
import scripts.config;
import std.json;
import std.array;
import raylib_lights;

// Constants
private const float TWO_PI = 2.0f * std.math.PI;
private const float FULL_ROTATION = 360.0f;
private const float HALF_ROTATION = 180.0f;

OBB[] collisionOBBs;
OBB playerOBB;
bool collisionDetected = false;

void parseSceneFile(string path) {
    collisionOBBs = [];
    foreach(model; floorModel) {
        UnloadModel(model);
    }
    
    // Clear dynamic arrays
    modelLocationSize = [];
    modelLocationRotate = [];
    rotateAngle = [];
    modelPosition = [];
    floorModel = [];
    
    JSONValue scene = parseJSON(readText(path));
    JSONValue objects = scene["objects"];
    for (int i = 0; i < objects.array.length; i++) {
        switch (objects[i]["type"].str) {
            case "model":
                model_location_path = cast(char*)toStringz(objects[i]["modelPath"].str);
                JSONValue scale = objects[i]["scale"];
                JSONValue position = objects[i]["position"];
                JSONValue rotation = objects[i]["rotation"];
                
                // Append to dynamic arrays
                modelPosition ~= Vector3(position["x"].get!float, position["y"].get!float, position["z"].get!float);
                modelLocationSize ~= Vector3(scale["x"].get!float, scale["y"].get!float, scale["z"].get!float);
                modelLocationRotate ~= Vector3(rotation["x"].get!float, rotation["y"].get!float, rotation["z"].get!float);
                rotateAngle ~= objects[i]["rotationAngle"].get!float;
                floorModel ~= LoadModel(model_location_path);
                break;
            
            case "light":
                JSONValue position = objects[i]["position"];
                JSONValue color = objects[i]["color"];
                light_pos ~= LightEngine(Vector3(position["x"].get!float, position["y"].get!float, 
                position["z"].get!float), Color(color["r"].get!int.to!ubyte, color["g"].get!int.to!ubyte, 
                color["b"].get!int.to!ubyte, color["a"].get!int.to!ubyte));
                break;
            
            case "collision":
                JSONValue position = objects[i]["position"];
                JSONValue size = objects[i]["size"];
                JSONValue rotation = objects[i]["rotation"];
                
                OBB newOBB;
                newOBB.center = Vector3(position["x"].get!float, 
                                    position["y"].get!float,
                                    position["z"].get!float);
                newOBB.halfExtents = Vector3(size["x"].get!float/2,
                                            size["y"].get!float/2,
                                            size["z"].get!float/2);
                newOBB.rotation = QuaternionFromEuler(rotation["x"].get!float * DEG2RAD,
                                                    rotation["y"].get!float * DEG2RAD,
                                                    rotation["z"].get!float * DEG2RAD);
                collisionOBBs ~= newOBB;
                break;
            default:
                break;
        }
    }
    JSONValue environment = scene["environment"];
    texture_skybox = LoadTexture(cast(char*)environment["skybox"].str);
}

void updatePlayerOBB(ref OBB playerOBB, Vector3 playerPosition, Vector3 modelCharacterSize, float playerRotation)
{
    playerOBB.center = Vector3(playerPosition.x, 
                             playerPosition.y + modelCharacterSize.y/2,
                             playerPosition.z);
    playerOBB.halfExtents = Vector3(modelCharacterSize.x/2, 
                                  modelCharacterSize.y/2, 
                                  modelCharacterSize.z/2);
    playerOBB.rotation = QuaternionFromAxisAngle(Vector3(0, 1, 0), playerRotation * DEG2RAD);
}

float playerModelRotation = 180;
bool isMoving = false;

void controlFunction(ref Camera3D camera, ref Vector3 cubePosition,
                    char fwd, char bkd, char lft, char rgt, 
                    bool allowControl, float deltaTime, float cameraSpeed) 
{
    // Early exit if control is disabled or cube is moving
    if (!allowControl || isCubeMoving) return;

    // Calculate forward and right vectors for movement
    Vector3 forward = Vector3Normalize(Vector3Subtract(camera.target, camera.position));
    forward.y = 0; // Keep movement horizontal
    Vector3 right = Vector3Normalize(Vector3CrossProduct(forward, camera.up));
    
    // Initialize movement vector
    Vector3 movement = Vector3(0, 0, 0);
    
    // Input detection (keyboard and gamepad)
    bool isMovingForward = IsKeyDown(fwd) || 
                         GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_Y) < -0.3 || 
                         IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP);
    
    bool isMovingBackward = IsKeyDown(bkd) || 
                          GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_Y) > 0.3 || 
                          IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN);
    
    bool isMovingLeft = IsKeyDown(lft) || 
                      GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_X) < -0.3 || 
                      IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT);
    
    bool isMovingRight = IsKeyDown(rgt) || 
                       GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_X) > 0.3 || 
                       IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT);

    // Calculate player rotation based on movement direction
    if (isMovingForward && isMovingLeft) {
        playerModelRotation = 45.0f;
    } else if (isMovingForward && isMovingRight) {
        playerModelRotation = 315.0f;
    } else if (isMovingBackward && isMovingLeft) {
        playerModelRotation = 135.0f;
    } else if (isMovingBackward && isMovingRight) {
        playerModelRotation = 225.0f;
    } else if (isMovingForward) {
        playerModelRotation = 0.0f;
    } else if (isMovingBackward) {
        playerModelRotation = 180.0f;
    } else if (isMovingLeft) {
        playerModelRotation = 90.0f;
    } else if (isMovingRight) {
        playerModelRotation = 270.0f;
    } else {
        isMoving = false;
    }

    // Apply movement based on input
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

    // Handle sprinting
    if ((IsKeyDown(KeyboardKey.KEY_LEFT_SHIFT) || 
        IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_LEFT)) && isMoving) 
    {
        float startTime = GetFrameTime();
        if (stamina <= 10.0f) {
            movement *= 1.07f;
            stamina -= startTime * 2;
        } else {
            movement *= 1.7f;
        }
        stamina -= startTime * 4;
    }

    // Only proceed if there's actual movement
    if (!Vector3Equals(movement, Vector3Zero())) {
        // Normalize and scale movement
        if (dungeonCrawlerMode) {
            movement = Vector3Normalize(movement);
            movement = Vector3Scale(movement, 0.5f);
        } else {
            movement = Vector3Scale(movement, cameraSpeed * deltaTime * 3.0f);
        }

        // Calculate proposed new position
        Vector3 proposedPosition = cubePosition + movement;
        
        // Create OBB for proposed position
        OBB proposedOBB;
        proposedOBB.center = Vector3(proposedPosition.x,
                                proposedPosition.y + collisionCharacterSize.y/2,
                                proposedPosition.z);
        proposedOBB.halfExtents = collisionCharacterSize/2;
        proposedOBB.rotation = QuaternionFromAxisAngle(Vector3(0, 1, 0), playerModelRotation * DEG2RAD);
        collisionDetected = false;
        foreach(obb; collisionOBBs) {
            if(checkCollisionOBBvsOBB(proposedOBB, obb)) {
                collisionDetected = true;
                break;
            }
        }

        // Only apply movement if no collision detected
        if(!collisionDetected) {
            camera.position += movement;
            camera.target += movement;
            cubePosition += movement;
            
            // Increment step counter if not in friendly zone
            if (!friendlyZone) playerStepCounter++;
        }
    }

    // Update player's actual bounding box
    updatePlayerOBB(playerOBB, cubePosition, collisionCharacterSize, playerModelRotation);
}

void drawDebugCollisions() {
    BeginMode3D(camera);
    
    // Draw player OBB
    drawWireframe(playerOBB, Colors.RED);
    
    // Draw other collision OBBs
    foreach(obb; collisionOBBs) {
        drawWireframe(obb, Colors.BLUE);
    }
    
    EndMode3D();
}

void rotateScriptCamera(ref Camera3D camera, ref Vector3 cubePosition, ref float cameraAngle, float targetAngle,
                         float rotationSpeed, float radius, float deltaTime) {
    if (!isCameraRotating) return;
    oldDegree = cameraAngle;
    if (rotationSpeed != 0.0) {
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
            float rightStickX = GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_RIGHT_X);
            if (fabs(rightStickX) > 0.3) {
                cameraAngle = fmod(cameraAngle + rotationStep * rightStickX, 360.0f);
                if (cameraAngle < 0) cameraAngle += 360.0f;
            }

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

void drawScene(Camera3D camera, Vector3 cubePosition, float cameraAngle, 
                Model[] cubeModels, Model playerModel) {
    float[3] cameraPos = [camera.position.x, camera.position.y, camera.position.z];
    if (shaderEnabled) SetShaderValue(shader, shader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW], &cameraPos[0], ShaderUniformDataType.SHADER_UNIFORM_VEC3);
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
        modelCharacterSize, Colors.WHITE);
    }
    // Draw floor model
    for (int i = 0; i < floorModel.length; i++) {
        DrawModelEx(floorModel[i], modelPosition[i], modelLocationRotate[i], rotateAngle[i], modelLocationSize[i], Colors.WHITE);
    }
    if (showDebug) drawDebugCollisions();
    EndMode3D();
}