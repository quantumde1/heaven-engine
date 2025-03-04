module scene.loader;

import std.stdio;

import raylib;

import scene.objects;

class Scene {
    Camera3D camera;
    this(Camera3D camera) {
        this.camera = camera;
    }
}

class NPC {

}