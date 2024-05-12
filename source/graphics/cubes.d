module graphics.cubes;

import raylib;
import std.typecons : Nullable;
import graphics.main_cycle;

struct Cube {
    string name;
    string[] text;
    int emotion;
    BoundingBox boundingBox;
    Vector3 startPosition;
    Vector3 endPosition;
    float moveStartTime;
    float moveDuration;
    bool isMoving;
    Vector3[] moveQueuePositions;
    float[] moveQueueDurations;
}

nothrow startCubeMove(ref Cube cube, Vector3 endPosition, float duration) {
    cube.moveQueuePositions ~= endPosition;
    cube.moveQueueDurations ~= duration;
    if (!cube.isMoving) {
        beginNextMove(cube);
    }
}

nothrow beginNextMove(ref Cube cube) {
    if (cube.moveQueuePositions.length > 0 && cube.moveQueueDurations.length > 0) {
        allowControl = false;
        cube.startPosition = cube.boundingBox.min;
        cube.endPosition = cube.moveQueuePositions[0];
        cube.moveStartTime = GetTime();
        cube.moveDuration = cube.moveQueueDurations[0];
        cube.isMoving = true;
        cube.moveQueuePositions = cube.moveQueuePositions[1..$];
        cube.moveQueueDurations = cube.moveQueueDurations[1..$];
    } else {
        allowControl = true;
    }
}

Vector3 vector3Lerp(Vector3 start, Vector3 end, float amount) {
    return Vector3(
        start.x + amount * (end.x - start.x),
        start.y + amount * (end.y - start.y),
        start.z + amount * (end.z - start.z)
    );
}

bool isAnyCubeMoving() {
    foreach (cube; cubes) {
        if (cube.isMoving) return true;
    }
    return false;
}

nothrow addCube(Vector3 position, string name, string[] text, int emotion) {
    Cube cube;
    cube.name = name;
    cube.text = text;
    cube.emotion = emotion;
    cube.boundingBox = BoundingBox(Vector3Subtract(position, Vector3(0.0f, 0.0f, 0.0f)), 
                                   Vector3Add(position, Vector3(2.0f, 2.0f, 2.0f)));
    cubes ~= cube;
}
