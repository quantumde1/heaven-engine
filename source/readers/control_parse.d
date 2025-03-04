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
                case "right":
                    controlButtons[3] = value;
                    break;
                case "left":
                    controlButtons[2] = value;
                    break;
                case "forward":
                    controlButtons[0] = value;
                    break;
                case "backward":
                    controlButtons[1] = value;
                    break;
                default:
                    break;
            }
        }
    }
    return controlButtons;
}
