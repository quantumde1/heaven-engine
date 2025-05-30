// quantumde1 developed software, licensed under MIT license.
module graphics.cubes;

import raylib;
import std.typecons : Nullable;
import variables;
import std.stdio;
import scripts.config;

//This is a cube structure. Here we're specify all informations which need for cube initializing and moving.
struct Cube
{
    string name;
    string[] text;
    char* emotion;
    int choicePage;
    BoundingBox boundingBox;
    Vector3 startPosition;
    Vector3 endPosition;
    float moveStartTime;
    float moveDuration;
    bool isMoving;
    bool isLoaded;
    Vector3[] moveQueuePositions;
    float[] moveQueueDurations;
    float rotation;
}

struct DialogNoCube
{
    string name;
    string[] text;
    int emotion;
    int choicePage;
}

//Function for init cube movement
nothrow startCubeMove(ref Cube cube, Vector3 endPosition, float duration)
{
    // adding positions and speed to initialized cube
    cube.moveQueuePositions ~= endPosition;
    cube.moveQueueDurations ~= duration;
    // if cube is not moving, we'll start this process via next function, haha
    if (!cube.isMoving)
    {
        beginNextMove(cube);
    }
}

//function for checking cube movement now, and to which position we need to move it
nothrow beginNextMove(ref Cube cube)
{
    //checking if cube movement is not last in massive and speed is more than 0
    if (cube.moveQueuePositions.length > 0 && cube.moveQueueDurations.length > 0)
    {
        allowControl = false;
        cube.startPosition = cube.boundingBox.min;
        cube.endPosition = cube.moveQueuePositions[0];
        cube.moveStartTime = GetTime();
        cube.moveDuration = cube.moveQueueDurations[0];
        cube.isMoving = true;
        cube.moveQueuePositions = cube.moveQueuePositions[1 .. $];
        cube.moveQueueDurations = cube.moveQueueDurations[1 .. $];
    }
    else
    {
        cube.isMoving = false;
        allowControl = true;
    }
}

//Interpolation movement. Idk how this implemented cuz it was made not by me.
Vector3 vector3Lerp(Vector3 start, Vector3 end, float amount)
{
    return Vector3(
        start.x + amount * (end.x - start.x),
        start.y + amount * (end.y - start.y),
        start.z + amount * (end.z - start.z)
    );
}

//check is any cube moving
bool isAnyCubeMoving()
{
    //checking massive of cubes
    foreach (cube; cubes)
    {
        if (cube.isMoving)
        {
            return true;
        }
    }
    return false;
}

import std.math;

void rotateCube(ref Cube cube, float targetAngle, float rotationSpeed, float deltaTime)
{
    cube.rotation = targetAngle;
}

//adding cubes to map
nothrow addCube(Vector3 position, string name, string[] text, char* emotion, int choicePage)
{
    //adding all needed for cube struct
    Cube cube;
    cube.name = name;
    cube.text = text;
    cube.emotion = emotion;
    cube.choicePage = choicePage;
    //setting collision
    cube.boundingBox = BoundingBox(Vector3Subtract(position, Vector3(0.0f, 0.0f, 0.0f)),
        Vector3Add(position, Vector3(1.0f, 1.0f, 1.0f)));
    //adding to massive
    cubes ~= cube;
}

nothrow void removeCube(string name)
{
    // Find the index of the cube in the array by name
    int indexToRemove = -1;
    foreach (index, cube; cubes)
    {
        try
        {
            debug debug_writeln("cube name:", cube.name, " cube index:", index);
        }
        catch (Exception e)
        {
        }
        if (cube.name == name)
        {
            indexToRemove = cast(int) index;
            break;
        }
    }

    // If the cube is found, remove it from the array
    if (indexToRemove != -1)
    {
        cubes = cubes[0 .. indexToRemove] ~ cubes[indexToRemove + 1 .. cubes.length];
    }
}