module system.config;

import std.stdio;
import std.file;
import std.string;
import std.range;
import variables;
import std.conv;
import system.abstraction;

nothrow char parseConf(string filename, string type)
{
    try
    {
        auto file = File(filename);
        auto config = file.byLineCopy();

        // Create a mapping of types to their corresponding prefixes
        auto typeMap = [
            "sound": "SOUND:",
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
                    debug debugWriteln("Value for ", type, ": ", button);
                    return button.front.to!char;
                }
            }
        }
    }
    catch (Exception e)
    {
        try
        {
            debugWriteln("Error parsing config: " ~ e.msg);
        }
        catch (Exception e)
        {
        }
    }
    return 'E';
}

SystemSettings loadSettingsFromConfigFile()
{
    return SystemSettings(
        parseConf("conf/settings.conf", "right"),
        parseConf("conf/settings.conf", "left"),
        parseConf("conf/settings.conf", "backward"),
        parseConf("conf/settings.conf", "forward"),
        parseConf("conf/settings.conf", "dialog"),
        parseConf("conf/settings.conf", "opmenu"),
        parseConf("conf/settings.conf", "sound")
    );
}