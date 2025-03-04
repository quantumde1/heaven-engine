import std.stdio;

import engine.engine;
import readers.control_parse;
import player.controls;

void main() {
    writeln("Starting \"Amaterasu\" Engine.(heaven ver.2)");
    char[4] buttonLayout = readControlsFromFile("conf/layout.conf");
    ControlConfig controls = ControlConfig(buttonLayout[0], buttonLayout[1], buttonLayout[2], buttonLayout[3]);
    Engine engine = new Engine(controls);
    engine.engineStarter();
    engine.engineConfigurator();
    engine.engineMain();
}