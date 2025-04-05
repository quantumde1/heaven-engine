module scene.objects;

import std.stdio;

import raylib;

class Object3D {
    Model model;
    Vector3 coordinates;
    Vector3 scale;
    float rotationAngle;
    this(Model model, Vector3 coordinates, Vector3 scale, float rotationAngle) {
        this.model = model;
        this.coordinates = coordinates;
        this.scale = scale;
        this.rotationAngle = rotationAngle;
    }
}