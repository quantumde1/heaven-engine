module graphics.video_playback;

import raylib;
import variables;

extern (C) int testPlayback(char* argv, int gamepadint);
int playVideo(char* argv) {
    DisableCursor();
    int test = testPlayback(argv, gamepadInt);
    if (test == 1488) {
        videoFinished = true;
    }
    return 0;
}
