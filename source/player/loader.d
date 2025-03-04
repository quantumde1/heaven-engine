module player.loader;

import std.stdio;

import raylib;

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

class Player : PartyMember {
    Model model;
    Vector3 coordinates;
    this(string name, int health, int experience, int level, Model model, Vector3 coordinates) {
        super(name, health, experience, level);
        this.model = model;
        this.coordinates = coordinates;
    }

    void playAnimation() {
        
    }
}