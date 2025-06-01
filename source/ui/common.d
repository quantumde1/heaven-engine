// quantumde1 developed software, licensed under MIT license.
module ui.common;

import raylib;
import std.string;
import std.conv;
import variables;
import scripts.config;

const int PLAYER_HEALTH_BAR_X = 10;
const float PLAYER_HEALTH_BAR_WIDTH = 300.0f;
const float PLAYER_HEALTH_BAR_HEIGHT = 30.0f;
const int PLAYER_HEALTH_BAR_Y_OFFSET = 600;
enum FadeIncrement = 0.02f;

void fadeEffect(float alpha, bool fadeIn, void delegate(float alpha) renderer)
{
    while (fadeIn ? alpha < 2.0f : alpha > 0.0f)
    {
        alpha += fadeIn ? FadeIncrement : -FadeIncrement;
        BeginDrawing();
        ClearBackground(Colors.BLACK);
        renderer(alpha);
        EndDrawing();
    }
}