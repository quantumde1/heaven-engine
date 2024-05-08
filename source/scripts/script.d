module script;

import std.stdio;
import std.file;
import std.string;
import std.range;

void debug_print(string info) {
    if (readText("conf/build_type.conf").strip() == "debug") {
        writeln("DEBUG:: ", info);
    } else if (readText("conf/build_type.conf").strip() == "release") {
        writeln("running release build");
        return;
    } else {
        writeln("error: no build type specified");
        return;
    }
}

char parse_conf(string filename, string type) {
    auto file = File(filename);
    auto config = file.byLineCopy();
    foreach (line; config) {
        auto trimmedLine = strip(line);
        if (trimmedLine.startsWith("BACKWARD:") && type == "backward") {
            auto back = trimmedLine["BACKWARD:".length .. $].strip();
            debug_print(back);
            return cast(char)back.front;
        } else if (trimmedLine.startsWith("FORWARD:") && type == "forward") {
            auto up = trimmedLine["FORWARD:".length .. $].strip();
            debug_print(up);
            return cast(char)up.front;
        } else if (trimmedLine.startsWith("RIGHT:") && type == "right") {
            auto right = trimmedLine["RIGHT:".length .. $].strip();
            debug_print(right);
            return cast(char)right.front;
        } else if (trimmedLine.startsWith("LEFT:") && type == "left") {
            auto left = trimmedLine["LEFT:".length .. $].strip();
            debug_print(left);
            return cast(char)left.front;
        } else if (trimmedLine.startsWith("DIALOG:") && type == "dialog") {
            auto dialog = trimmedLine["DIALOG:".length .. $].strip();
            debug_print(dialog);
            return cast(char)dialog.front;
        }
    }
    return 'E';
}