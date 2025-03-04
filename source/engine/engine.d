module engine.engine;

import std.string;
import std.stdio;

import multimedia.playback;
import player.controls;
import player.loader;
import scene.loader;
import scene.objects;
import ui.widgets;
import readers.control_parse;

import raylib;

class Engine {
    private:
        char[4] buttonLayout; //if someone here would need it, but not outside

    public:
        Player player;
        ControlConfig contols;
        int screenWidth;
        int screenHeight;
        string nameOfWindow;

    void engineConfigurator() {
        //configure buttons first
        buttonLayout = readControlsFromFile("conf/layout.conf");
        //models
        Model playerModel = LoadModel("res/mc.glb");
        player = new Player("quantumde1", 120, 0, 1, playerModel, Vector3(0, 0, 0));
        //controls
        contols = new ControlConfig(buttonLayout[0], buttonLayout[1], buttonLayout[2], buttonLayout[3]);
    }

    void engineStarter() {
        InitWindow(screenWidth, screenHeight, nameOfWindow.toStringz);
        InitAudioDevice();
    }

    void engineMain() {

    }
}