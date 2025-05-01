// quantumde1 developed software, licensed under BSD-0-Clause license.
module scripts.config;

import std.stdio;
import std.file;
import std.string;
import std.range;
import variables;
import std.conv;

string check_build_settings(string filename, string checked_what) nothrow
{
    try
    {
        auto file = File(filename);
        auto config = file.byLineCopy();
        foreach (line; config)
        {
            auto trimmedLine = strip(line);
            if (checked_what == "audio" && trimmedLine.startsWith("SOUND_STATE:"))
            {
                return trimmedLine["SOUND_STATE:".length .. $].strip();
            }
        }
    }
    catch (Exception e)
    {
        try
        {
            debug_writeln("Error reading settings: " ~ e.msg);
        }
        catch (Exception e)
        {

        }
    }
    return "ERROR";
}

nothrow bool isReleaseBuild()
{
    try
    {
        debug
        {
            return false;
        }
        return true;
    }
    catch (Exception e)
    {
        debug_writeln("Error checking release build: " ~ e.msg);
    }
}

nothrow bool isAudioEnabled()
{
    try
    {
        auto audioType = check_build_settings("conf/configuration.conf", "audio");
        return audioType == "ON";
    }
    catch (Exception e)
    {
        debug_writeln("Error getting audio state: " ~ e.msg);
    }
}

import std.format;

nothrow void debug_writeln(A...)(A args)
{
    debug
    {
        try
        {
            writeln("INFO: ENGINE: ", args);
        }
        catch (Exception e)
        {

        }
    }
}

nothrow char parse_conf(string filename, string type)
{
    try
    {
        auto file = File(filename);
        auto config = file.byLineCopy();

        // Create a mapping of types to their corresponding prefixes
        auto typeMap = [
            "backward": "BACKWARD:",
            "forward": "FORWARD:",
            "right": "RIGHT:",
            "left": "LEFT:",
            "dialog": "DIALOG:",
            "opmenu": "OPMENU:"
        ];

        // Check if the provided type exists in the map
        if (type in typeMap)
        {
            auto prefix = typeMap[type];
            foreach (line; config)
            {
                auto trimmedLine = strip(line);
                if (trimmedLine.startsWith(prefix))
                {
                    auto button = trimmedLine[prefix.length .. $].strip();
                    debug debug_writeln("Button for ", type, ": ", button);
                    return button.front.to!char;
                }
            }
        }
    }
    catch (Exception e)
    {
        try
        {
            debug_writeln("Error parsing config: " ~ e.msg);
        }
        catch (Exception e)
        {
            // Handle any exceptions that may occur during logging
        }
    }
    return 'E';
}