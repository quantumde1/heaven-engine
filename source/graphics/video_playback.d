module graphics.video_playback;

import std.stdio;
import raylib;
import raylib.rlgl;
import core.stdc.stdlib;
import core.stdc.string;
import core.thread;
import variables;
import core.sync.mutex;
import std.array;

extern (C) int testPlayback(char* argv, int gamepadint);
int playVideo(char* argv) {
    // Load and play music
    int test = testPlayback(argv, gamepadInt);
    while (test != 1488) {
        
    }
    if (test == 1488) {
        videoFinished = true;
    }
    return 0;
}
