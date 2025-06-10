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

#include <stdatomic.h>  // Для атомарных операций (если доступно)

// Заменяем int на atomic_int для thread-safety
atomic_int playbackNeeded = 0;
atomic_int sfxNeeded = 0;

// SFX variables
#define LEFT 255
#define CENTER 255
#define RIGHT 255
static sfxhnd_t current_sfx = 0;
static uint8_t sfx_volume = 255;
static int sfx_pan = CENTER;

static void* audio_thread(void *filename) {
    while (atomic_load(&playbackNeeded)) {  // Проверяем флаг атомарно
        if (adx_dec(concat_strings(PREFIX, (char*)filename), 1) < 1) {
            printf("Error: invalid ADX");
            return NULL;
        }

        // Ждём инициализации драйвера
        while (snddrv.drv_status == SNDDRV_STATUS_NULL) {
            thd_pass();
            if (!atomic_load(&playbackNeeded)) return NULL;  // Выход, если остановлено
        }

        // Ждём завершения воспроизведения (с проверкой флага)
        while (snddrv.drv_status != SNDDRV_STATUS_NULL) {
            thd_sleep(50);
            if (!atomic_load(&playbackNeeded)) {
                adx_stop();
                printf("stopping playback");
                return NULL;
            }
        }
    }
    return NULL;
}

void loadMusic(char* filename) {
    printf("Init audio playback");
    thd_create(0, audio_thread, filename);
}

void playMusic() {
    atomic_store(&playbackNeeded, 1);  // Атомарная установка флага
}

void stopMusic() {
    atomic_store(&playbackNeeded, 0);  // Атомарная установка флага
}

void unloadMusic() {

}

void playSfx(char* filename) {
    printf("%s\n", "sfx called in audio.c");
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