module player.loader;

import std.stdio;

import raylib;

import scene.objects;

class PartyMember {
    string name;
    int health;
    int experience;
    int level;
    float rotationAngle;
    this(string name, int health, int experience, int level) {
        this.name = name;
        this.health = health;
        this.experience = experience;
        this.level = level;
    }
}

class Player : Object3D {
    PartyMember partyMember;
    float speed;

    this(string name, int health, int experience, int level, Model model, Vector3 coordinates, Vector3 scale, 
    float speed, float rotationAngle) {
        super(model, coordinates, scale, rotationAngle);
        this.partyMember = new PartyMember(name, health, experience, level);
        this.speed = speed;
    }
}