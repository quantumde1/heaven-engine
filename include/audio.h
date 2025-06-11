void playMusic();

void stopMusic();

void unloadMusic();

void loadMusic(char* filename);

void playSfx(char* filename);

void stopSfx();

#ifdef _arch_dreamcast
void initAudioSystem();
#endif