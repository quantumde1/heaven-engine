#include <raylib.h>
#include <unistd.h>
#include <stdio.h>

#include "../../include/variables.h"
#include "../../include/abstraction.h"
#include "../../include/audio.h"

#ifdef _arch_dreamcast

#include <kos/init.h>
#include <kos.h>
#include <dc/sound/sound.h>
#include <dc/sound/sfxmgr.h>

#include <adx/adx.h> /* ADX Decoder Library */
#include <adx/snddrv.h> /* Direct Access to Sound Driver */

int playbackNeeded = 0;
int sfxNeeded = 0;

// SFX variables
#define LEFT 255
#define CENTER 255
#define RIGHT 255
static sfxhnd_t current_sfx = 0;
static uint8_t sfx_volume = 255;
static int sfx_pan = CENTER;

static void* audio_thread(void *filename) {
    while(playbackNeeded == 1) {
        play_again:
        if( adx_dec( concat_strings(PREFIX, (char*)filename), 1 ) < 1 ) {
            printf("Error: invalid ADX");
            return NULL;
        }
        while( snddrv.drv_status == SNDDRV_STATUS_NULL ) {
            thd_pass();
        }
        while (snddrv.drv_status != SNDDRV_STATUS_NULL ) {
            thd_sleep(50);
        }
        if (snddrv.drv_status == SNDDRV_STATUS_NULL) {
            printf("audio loop");
            goto play_again;
        }
    }
    return NULL;
}

void loadMusic(char* filename) {
    printf("Init audio playback");
    thd_create(0, audio_thread, filename);
}

void playMusic() {
    playbackNeeded = 1;
}

void stopMusic() {
    playbackNeeded = 0;
}

void unloadMusic() {

}

void playSfx(char* filename) {
    printf("%s\n", "sfx called in audio.c");
    if(current_sfx) {
        snd_sfx_unload(current_sfx);
    }
    FILE *file = fopen(concat_strings(PREFIX, filename), "r");
    if (file != NULL) {
        printf("%s\n", "loading sfx");
        // Load new SFX
        current_sfx = snd_sfx_load(concat_strings( PREFIX, filename ));
        if(current_sfx) {
            snd_sfx_play(current_sfx, sfx_volume, sfx_pan);
        }
    } else {
        printf("%s\n", "No such file or directory");
    }
}

void stopSfx() {
    if(current_sfx) {
        snd_sfx_stop(current_sfx);
        snd_sfx_unload(current_sfx);
    }
}

void initAudioSystem() {
    // Initialize sound system
    snd_init();
}

void shutdownAudioSystem() {
    // Cleanup SFX
    if(current_sfx) {
        snd_sfx_unload(current_sfx);
        current_sfx = 0;
    }
    
    // Shutdown sound system
    snd_shutdown();
}

#else

void loadMusic(char* filename) {
    BGM = LoadMusicStream(filename);
}

void playMusic() {
    PlayMusicStream(BGM);
}

void stopMusic() {
    StopMusicStream(BGM);
}

void unloadMusic() {
    UnloadMusicStream(BGM);
}

void playSfx(char* filename) {
    printf("%s\n", "loading sfx");
    SFX = LoadSound(concat_strings(PREFIX, filename));
    PlaySound(SFX);
    return;
}

void stopSfx() {
    StopSound(SFX);
    return;
}
#endif