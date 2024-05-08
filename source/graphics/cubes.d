module graphics.cubes;

import raylib;
import std.typecons : Nullable;

struct Cube {
    string name;
    string text;
    int emotion;
    BoundingBox boundingBox;
}

Cube[] cubes;

nothrow addCube(Vector3 position, string name, string text, int emotion) {
    Cube cube;
    cube.name = name;
    cube.text = text;
    cube.emotion = emotion;
    cube.boundingBox = BoundingBox(Vector3Subtract(position, Vector3(0.5f, 0.5f, 0.5f)), 
                                   Vector3Add(position, Vector3(3.0f, 3.0f, 3.0f)));
    cubes ~= cube;
}