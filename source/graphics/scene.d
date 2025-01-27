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

Mesh createCubeMesh(float size) {
    // Создаем меш куба с заданным размером
    Mesh cubeMesh = GenMeshCube(size, size, size);
    return cubeMesh;
}

void SaveVerticesToFile(const char *filename, Mesh mesh) {
    FILE *file = fopen(filename, "w");
    if (!file) {
        printf("Ошибка при открытии файла для записи\n");
        return;
    }

    for (int i = 0; i < mesh.triangleCount; i++) {
        int index1 = mesh.indices[i * 3 + 0];
        int index2 = mesh.indices[i * 3 + 1];
        int index3 = mesh.indices[i * 3 + 2];

        fprintf(file, "Triangle %d:\n", i);
        fprintf(file, "  Vertex 1: (%f, %f, %f)\n", mesh.vertices[index1 * 3 + 0], mesh.vertices[index1 * 3 + 1], mesh.vertices[index1 * 3 + 2]);
        fprintf(file, "  Vertex 2: (%f, %f, %f)\n", mesh.vertices[index2 * 3 + 0], mesh.vertices[index2 * 3 + 1], mesh.vertices[index2 * 3 + 2]);
        fprintf(file, "  Vertex 3: (%f, %f, %f)\n", mesh.vertices[index3 * 3 + 0], mesh.vertices[index3 * 3 + 1], mesh.vertices[index3 * 3 + 2]);
    }

    fclose(file);
}

void DrawMeshFromFileDataScaled(Mesh mesh, Vector3 position, Vector3 scale, Color color) {
    // Проходим по всем треугольникам меша
    for (int i = 0; i < mesh.triangleCount; i++) {
        // Получаем индексы вершин треугольника
        int index1 = mesh.indices[i * 3 + 0];
        int index2 = mesh.indices[i * 3 + 1];
        int index3 = mesh.indices[i * 3 + 2];

        // Получаем координаты вершин и применяем масштабирование
        Vector3 v1 = Vector3(
            mesh.vertices[index1 * 3 + 0] * scale.x,
            mesh.vertices[index1 * 3 + 1] * scale.y,
            mesh.vertices[index1 * 3 + 2] * scale.z
        );

        Vector3 v2 = Vector3(
            mesh.vertices[index2 * 3 + 0] * scale.x,
            mesh.vertices[index2 * 3 + 1] * scale.y,
            mesh.vertices[index2 * 3 + 2] * scale.z
        );

        Vector3 v3 = Vector3(
            mesh.vertices[index3 * 3 + 0] * scale.x,
            mesh.vertices[index3 * 3 + 1] * scale.y,
            mesh.vertices[index3 * 3 + 2] * scale.z
        );

        // Применяем позицию модели к вершинам
        v1 = Vector3Add(v1, position);
        v2 = Vector3Add(v2, position);
        v3 = Vector3Add(v3, position);

        // Рисуем треугольник
        DrawTriangle3D(v1, v2, v3, color);
    }
}

void LoadVerticesFromFile(const char *filename, Mesh *mesh, Vector3 multiplier) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        printf("Ошибка при открытии файла для чтения\n");
        return;
    }

    char[256] line; // Исправлено: правильный синтаксис для объявления массива
    int triangleIndex = -1;
    int vertexIndex = 0;

    while (fgets(cast(char*)line, cast(int)line.sizeof, file)) {
        if (sscanf(cast(char*)line, cast(char*)"Triangle %d:", &triangleIndex) == 1) {
            vertexIndex = 0; // Сброс индекса вершин для нового треугольника
        } else if (triangleIndex >= 0 && vertexIndex < 3) {
            float x, y, z;
            if (sscanf(cast(char*)line, cast(char*)"  Vertex %d: (%f, %f, %f)", &vertexIndex, &x, &y, &z) == 3) {
                // Умножаем координаты на multiplier
                x *= multiplier.x;
                y *= multiplier.y;
                z *= multiplier.z;
                int index = mesh.indices[triangleIndex * 3 + vertexIndex - 1]; // -1, так как vertexIndex начинается с 1
                mesh.vertices[index * 3 + 0] = x;
                mesh.vertices[index * 3 + 1] = y;
                mesh.vertices[index * 3 + 2] = z;
            }
        }
    }

    fclose(file);
}
import std.datetime;
Mesh mesh;
bool CheckCollisionWithVertices(Vector3 cubePosition, Mesh mesh, float threshold) {
    for (int i = 0; i < mesh.vertexCount; i++) {
        Vector3 vertexPosition = Vector3( mesh.vertices[i * 3 + 0], mesh.vertices[i * 3 + 1], mesh.vertices[i * 3 + 2] );
        if (Vector3Distance(cubePosition, vertexPosition) < threshold) {
            SysTime today = Clock.currTime().toUnixTime();
            debug_writeln(vertexPosition, today);
            return true;
        }
    }
    return false;
}

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
                pathToVertices[i] = objects[i]["collisionData"].get!string;
                // Проходим по всем мешам модели
                for (int meshIndex = 0; meshIndex < floorModel[i].meshCount; meshIndex++) {
                    debug_writeln("Loading vertice ", meshIndex, " from ", pathToVertices[i], " model name is ", to!string(model_location_path));
                    mesh = floorModel[i].meshes[meshIndex]; // Получаем текущий меш
                    LoadVerticesFromFile(toStringz(pathToVertices[i]), &mesh, modelLocationSize[i]);
                }
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


bool collisionPretty;

void inputName() {
    char[8] name;
    char[8] surname;
    int currentField = 0; // 0 for Name, 1 for Surname
    int letterCount = 0; // To track the number of letters in the input
        if (IsKeyPressed(KeyboardKey.KEY_ENTER)) {
            if (currentField == 0) {
                currentField = 1; // Move to Surname field
                letterCount = 0; // Reset letter count for surname
            } else {
                // Optionally handle submission of both fields
                // For example, print to console
                // Reset fields
                currentField = 0;
                letterCount = 0;
                name[0] = '\0';
                surname[0] = '\0';
            }
        }

        if (currentField == 0) {
            // Input for Name
            if (letterCount < 8 - 1) {
                if (IsKeyPressed(KeyboardKey.KEY_BACKSPACE)) {
                    name[--letterCount] = '\0'; // Remove last character
                } else {
                    for (int key = 32; key < 126; key++) {
                        if (IsKeyPressed(key)) {
                            name[letterCount++] = cast(char)key; // Add character
                            name[letterCount] = '\0'; // Null-terminate string
                        }
                    }
                }
            }
        } else {
            // Input for Surname
            if (letterCount < 8 - 1) {
                if (IsKeyPressed(KeyboardKey.KEY_BACKSPACE)) {
                    surname[--letterCount] = '\0'; // Remove last character
                } else {
                    for (int key = 32; key < 126; key++) {
                        if (IsKeyPressed(key)) {
                            surname[letterCount++] = cast(char)key; // Add character
                            surname[letterCount] = '\0'; // Null-terminate string
                        }
                    }
                }
            }
        }
        ClearBackground(Colors.RAYWHITE);

        DrawText("Enter your Name:", 10, 10, 20, Colors.DARKGRAY);
        DrawText(cast(char*)name, 10, 40, 20, Colors.BLACK);
        DrawText("Press Enter to continue to Surname", 10, 70, 20, Colors.DARKGRAY);

        if (currentField == 1) {
            DrawText("Enter your Surname:", 10, 100, 20,Colors.DARKGRAY);
            DrawText(cast(char*)surname, 10, 130, 20, Colors.BLACK);
            DrawText("Press Enter to submit", 10, 160, 20, Colors.DARKGRAY);
        }
}

void updateCameraAndCubePosition(ref Camera3D camera, ref Vector3 cubePosition, float cameraSpeed, float deltaTime,
                                 char fwd, char bkd, char lft, char rgt, bool allowControl, Cube[] cubes) {
    if (!allowControl || isCubeMoving) return;

    Vector3 forward = Vector3Normalize(Vector3Subtract(camera.target, camera.position));
    forward.y = 0;
    Vector3 right = Vector3Normalize(Vector3CrossProduct(forward, camera.up));

    float currentSpeedMultiplier = IsKeyDown(KeyboardKey.KEY_RIGHT_SHIFT) ? SpeedMultiplier : 3.0f;

    Vector3 movement = Vector3(0, 0, 0);
    if (IsKeyDown(fwd) || GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_Y) < -0.3 || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP)) movement += forward;
    if (IsKeyDown(bkd) || GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_Y) > 0.3 || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN)) movement -= forward;
    if (IsKeyDown(lft) || GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_X) < -0.3 || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT)) movement -= right;
    if (IsKeyDown(rgt) || GetGamepadAxisMovement(gamepadInt, GamepadAxis.GAMEPAD_AXIS_LEFT_X) > 0.3 || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT)) movement += right;

    if (!Vector3Equals(movement, Vector3Zero())) {
        if (dungeonCrawlerMode) {
            // Normalize movement to ensure it only moves in increments of 2.0
            movement = Vector3Normalize(movement);
            movement = Vector3Scale(movement, 0.5f); // Move exactly 2.0 units
        } else {
            movement = Vector3Scale(movement, cameraSpeed * deltaTime * currentSpeedMultiplier);
        }
        // Check for collisions before moving
        BoundingBox cubeBoundingBox;
        Nullable!Cube collidedCube = handleCollisions(cubePosition + movement, cubes, cubeBoundingBox);
        for (int j = 0; j < floorModel.length; j++) {
            for (int i = 0; i < floorModel[j].meshCount; i++) {
                if (CheckCollisionWithVertices(cubePosition, floorModel[j].meshes[i], 0.5)) {
                    collisionPretty = true;
                    debug_writeln("Collision state: ", collisionPretty);
                }
            }
        }
        if (collidedCube.isNull) {
            // No collision detected, move the cube
            camera.position += movement;
            camera.target += movement;
            cubePosition += movement;
            if (!friendlyZone) playerStepCounter++;
        } else {
            // Collision detected, handle response (e.g., stop movement or slide)
            // For simplicity, we will just not move the cube in this example.
        }
    }

    // Existing tracking logic
    if (!trackingCube.isNull) {
        Vector3 targetPosition = trackingCube.get.boundingBox.min + (trackingCube.get.boundingBox.max -
        trackingCube.get.boundingBox.min) / 2.0f;
        Vector3 direction = Vector3Normalize(Vector3Subtract(targetPosition, camera.position));
        camera.target = Vector3Lerp(camera.target, targetPosition, deltaTime * cameraSpeed);
        camera.position = Vector3Lerp(camera.position, Vector3Subtract(camera.target,
        Vector3Scale(direction, desiredDistance)), deltaTime * cameraSpeed);
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
            if (IsKeyDown(KeyboardKey.KEY_RIGHT)
            || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_TRIGGER_1)) {
                cameraAngle = fmod(cameraAngle + rotationStep, 360.0f);
                if (cameraAngle < 0) cameraAngle += 360.0f; // Ensure positive angle
            }
            if (IsKeyDown(KeyboardKey.KEY_LEFT)
            || IsGamepadButtonDown(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_TRIGGER_1)) {
                cameraAngle = fmod(cameraAngle - rotationStep, 360.0f);
                if (cameraAngle < 0) cameraAngle += 360.0f; // Ensure positive angle
            }
        } else {
            targetAngle = 90.0f;
            if (IsKeyPressed(KeyboardKey.KEY_LEFT)
            || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_LEFT_TRIGGER_1)) {
                cameraAngle = fmod(cameraAngle - targetAngle, 360.0f);
                if (cameraAngle < 0) cameraAngle += 360.0f; // Ensure positive angle
            }
            if (IsKeyPressed(KeyboardKey.KEY_RIGHT)
            || IsGamepadButtonPressed(gamepadInt, GamepadButton.GAMEPAD_BUTTON_RIGHT_TRIGGER_1)) {
                cameraAngle = fmod(cameraAngle + targetAngle, 360.0f);
                if (cameraAngle < 0) cameraAngle += 360.0f; // Ensure positive angle
            }
        }
    }

    // Update camera position
    float cameraX = cubePosition.x + radius * cos(cameraAngle * std.math.PI / 180.0f);
    float cameraZ = cubePosition.z + radius * sin(cameraAngle * std.math.PI / 180.0f);
    camera.position = Vector3(cameraX, camera.position.y, cameraZ);
}

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
    float playerRotation = (-cameraAngle * std.math.PI / 180.0f) + additionalRotation;
    if (drawPlayer == true) {
        DrawModelEx(playerModel, playerPosition, Vector3(0.0f, 1.0f, 0.0f), playerRotation * 180.0f / std.math.PI,
        Vector3(playerScale, playerScale, playerScale), Colors.WHITE);
    } else {
    }
    // Draw floor model
    for (int i = 0; i < floorModel.length; i++) {
        DrawModelEx(floorModel[i], modelPosition[i], modelLocationRotate[i], rotateAngle[i], modelLocationSize[i], Colors.WHITE);
    }
    EndMode3D();
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

Nullable!Cube handleCollisionsDialog(Vector3 cubePosition, Cube[] cubes, ref BoundingBox cubeBoundingBox) {
    // Define the bounding box for the cube at the current position
    // Expand the bounding box by 3.0f in all directions
    Vector3 expandedPosition = Vector3Subtract(cubePosition, Vector3(3.0f, 3.0f, 3.0f));
    Vector3 expandedSize = Vector3Add(cubePosition, Vector3(3.0f, 3.0f, 3.0f));

    cubeBoundingBox = BoundingBox(expandedPosition, expandedSize);

    // Check for collisions with other cubes
    foreach (cube; cubes) {
        if (CheckCollisionBoxes(cubeBoundingBox, cube.boundingBox)) {
            return Nullable!Cube(cube); // Return the collided cube
        }
    }

    return Nullable!Cube.init; // Return an empty Nullable!Cube if no collision is detected
}
