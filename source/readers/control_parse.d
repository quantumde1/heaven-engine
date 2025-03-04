module readers.control_parse;

import std.stdio;
import std.string;
import std.conv;
import std.file;

char[4] readControlsFromFile(string filepath) {
    string content = readText(filepath);
    char[4] controlButtons;
    foreach (line; splitLines(content)) {
        auto parts = split(line, "=");
        if (parts.length == 2) {
            string key = parts[0];
            char value = parts[1].to!char;
            switch (key) {
                case "left":
                    controlButtons[1] = value;
                    break;
                case "right":
                    controlButtons[0] = value;
                    break;
                case "forward":
                    controlButtons[3] = value;
                    break;
                case "backward":
                    controlButtons[2] = value;
                    break;
                default:
                    break;
            }
        }
    }
    writeln("Configured layout: ", controlButtons);
    return controlButtons;
}
