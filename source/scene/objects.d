module scene.objects;

import std.stdio;

import raylib;

class Object3D {
    Model model;
    Vector3 coordinates;
    Vector3 scale;
    this(Model model, Vector3 coordinates, Vector3 scale) {
        this.model = model;
        this.coordinates = coordinates;
        this.scale = scale;
    }
}