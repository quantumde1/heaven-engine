module graphics.effects;

import raylib;
import std.stdio;
import variables;
import std.string;
import scripts.config;
import std.algorithm;

int screenWidth;// = GetScreenWidth();
int screenHeight;// = GetScreenHeight();

Texture2D[] loadAnimationFramesUI(const string archivePath, const string animationName)
{
    screenWidth = GetScreenWidth();
    screenHeight = GetScreenHeight();
    Texture2D[] frames;
    uint frameIndex = 1;
    while (true)
    {
        string frameFileName = format("%s-%03d.png", animationName, frameIndex);
        uint image_size;
        debug debug_writeln(frameFileName);
        char* image_data = get_file_data_from_archive(toStringz(archivePath),
                toStringz(frameFileName), &image_size);
        if (image_data == null)
        {
            debug debug_writeln("exiting from load anim UI");
            break;
        }
        Image image = LoadImageFromMemory(".PNG", cast(const(ubyte)*) image_data, image_size);
        Texture2D texture = LoadTextureFromImage(image);
        UnloadImage(image);
        frames ~= texture;
        debug debug_writeln("Loaded frame for UI ", frameIndex, " - ", frameFileName);
        frameIndex++;
    }
    debug debug_writeln("Frames for ui animations length: ", frames.length);
    return frames;
}

void playUIAnimation(Texture2D[] frames)
{
    static float frameTime = 0.0f;
    
    if (playAnimation) {
        frameTime += GetFrameTime();
        
        while (frameTime >= frameDuration && frameDuration > 0) {
            frameTime -= frameDuration;
            currentFrame = cast(int)((currentFrame + 1) % frames.length);
        }

        int frameWidth = frames[currentFrame].width;
        int frameHeight = frames[currentFrame].height;
        
        DrawTexturePro(
            frames[currentFrame],
            Rectangle(0, 0, frameWidth, frameHeight),
            Rectangle(0, 0, screenWidth, screenHeight),
            Vector2(0, 0),
            0,
            Color(255, 255, 255, 127)
        );
    } else {
        frameTime = 0.0f;
        currentFrame = 0;
    }
}

Sound sfx;

void playSfx(string filename) {
    debug debug_writeln("Loading & playing SFX");
    sfx = LoadSound(filename.toStringz());
    PlaySound(sfx);
}