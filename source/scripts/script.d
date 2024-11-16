// quantumde1 developed software, licensed under BSD-0-Clause license.
module script;

import std.stdio;
import std.file;
import std.string;
import std.range;
import variables;
import std.conv;

string check_build_settings(string filename, string checked_what) nothrow {
    try {
        auto file = File(filename);
        auto config = file.byLineCopy();
        foreach (line; config) {
            auto trimmedLine = strip(line);
            if (checked_what == "build" && trimmedLine.startsWith("BUILD_TYPE:")) {
                return trimmedLine["BUILD_TYPE:".length .. $].strip();
            } else if (checked_what == "audio" && trimmedLine.startsWith("SOUND_STATE:")) {
                return trimmedLine["SOUND_STATE:".length .. $].strip();
            } else if (checked_what == "fight" && trimmedLine.startsWith("FIGHTING_MODE:")) {
                return trimmedLine["FIGHTING_MODE:".length .. $].strip();
            }
        }
    } catch (Exception e) {
        debug_print("Error reading build settings: " ~ e.msg);
    }
    return "ERROR";
}

nothrow bool isReleaseBuild() {
    try {
        auto buildType = check_build_settings("conf/build_type.conf", "build");
        return buildType == "RELEASE";
    } catch (Exception e) {
        debug_print("Error checking release build: " ~ e.msg);
    }
}

nothrow isGameFighting() {
    try {
        auto isFighting = check_build_settings("conf/build_type.conf", "fight");
        return isFighting == "ON";
    } catch (Exception e) {
    }
}
nothrow bool isAudioEnabled() {
    try {
        auto audioType = check_build_settings("conf/build_type.conf", "audio");
        return audioType == "ON";
    } catch (Exception e) {
        debug_print("Error checking audio state: " ~ e.msg);
    }
}

nothrow void debug_print(string info) {
    try {
    writeln("DEBUG:: ", info);
    } catch (Exception e) {

    }
}

nothrow char parse_conf(string filename, string type) {
    try {
        auto file = File(filename);
        auto config = file.byLineCopy();
        foreach (line; config) {
            auto trimmedLine = strip(line);
            if (type == "backward" && trimmedLine.startsWith("BACKWARD:")) {
                auto back = trimmedLine["BACKWARD:".length .. $].strip();
                if (!rel) debug_print(back);
                return back.front.to!char;
            } else if (type == "forward" && trimmedLine.startsWith("FORWARD:")) {
                auto forward = trimmedLine["FORWARD:".length .. $].strip();
                if (!rel) debug_print(forward);
                return forward.front.to!char;
            } else if (type == "right" && trimmedLine.startsWith("RIGHT:")) {
                auto right = trimmedLine["RIGHT:".length .. $].strip();
                if (!rel) debug_print(right);
                return right.front.to!char;
            } else if (type == "left" && trimmedLine.startsWith("LEFT:")) {
                auto left = trimmedLine["LEFT:".length .. $].strip();
                if (!rel) debug_print(left);
                return left.front.to!char;
            } else if (type == "dialog" && trimmedLine.startsWith("DIALOG:")) {
                auto dialog = trimmedLine["DIALOG:".length .. $].strip();
                if (!rel) debug_print(dialog);
                return dialog.front.to!char;
            }
             else if (type == "opmenu" && trimmedLine.startsWith("OPMENU:")) {
                auto opmenu = trimmedLine["OPMENU:".length .. $].strip();
                if (!rel) debug_print(opmenu);
                return opmenu.front.to!char;
            }
        }
    } catch (Exception e) {
        debug_print("Error parsing config: " ~ e.msg);
    }
    return 'E';
}