module player.loader;

import std.stdio;

import raylib;

import scene.objects;

class PartyMember {
    string name;
    int health;
    int experience;
    int level;
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

    this(string name, int health, int experience, int level, Model model, Vector3 coordinates, Vector3 scale, float speed) {
        super(model, coordinates, scale);
        this.partyMember = new PartyMember(name, health, experience, level);
        this.speed = speed;
    }

    void playAnimation() {
        
    }
}