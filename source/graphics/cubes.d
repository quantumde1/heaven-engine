module graphics.cubes;

import raylib;
import std.typecons : Nullable;

struct Cube {
    string name;
    string[] text; // Теперь это массив строк
    int emotion;
    BoundingBox boundingBox;
}


Cube[] cubes;

nothrow addCube(Vector3 position, string name, string[] text, int emotion) {
    Cube cube;
    cube.name = name;
    cube.text = text; // Теперь присваиваем массив строк
    cube.emotion = emotion;
    cube.boundingBox = BoundingBox(Vector3Subtract(position, Vector3(0.0f, 0.0f, 0.0f)), 
                                   Vector3Add(position, Vector3(2.0f, 2.0f, 2.0f)));
    cubes ~= cube;
}
