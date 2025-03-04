module player.controls;

import std.stdio;

class ControlConfig {
    int right;
    int left;
    int forward;
    int backward;
    this(int right, int left, int forward, int backward) {
        this.right = right;
        this.left = left;
        this.forward = forward;
        this.backward = backward;
    }
}