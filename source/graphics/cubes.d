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
}

nothrow startCubeMove(ref Cube cube, Vector3 endPosition, float duration) {
    isCubeMoving = true;
    cube.startPosition = cube.boundingBox.min;
    cube.endPosition = endPosition;
    cube.moveStartTime = GetTime();
    cube.moveDuration = duration;
    cube.isMoving = true;
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
