module graphics.video_playback;

import std.stdio;
import raylib;
import raylib.rlgl;
import core.stdc.stdlib;
import core.stdc.string;
import core.thread;
import vlc;
import variables;
import core.sync.mutex;

struct Video {
    uint texW, texH;
    float scale;
    Mutex mutex;
    Texture2D texture;
    ubyte* buffer;
    bool needUpdate;
    libvlc_media_player_t* player;
}

extern (C) void* begin_vlc_rendering(void* data, void** p_pixels) {
    auto video = cast(Video*)data;
    video.mutex.lock();
    *p_pixels = video.buffer;
    return null;
}

extern (C) void end_vlc_rendering(void* data, void* id, void* p_pixels) {
    auto video = cast(Video*)data;
    video.needUpdate = true;
    video.mutex.unlock();
}

extern (C) void videoEndCallback(void* data) {
    auto video = cast(Video*)data;
    videoFinished = true;
    writeln("Video ended");
    cleanup_video(video);
}

Video* add_new_video(libvlc_instance_t* libvlc, const(char)* src, const(char)* protocol) {
    auto video = cast(Video*)malloc(Video.sizeof);
    if (video is null) {
        writeln("Failed to allocate memory for video.");
        return null;
    }

    video.mutex = new Mutex;
    auto location = cast(char*)malloc(strlen(protocol) + strlen(src) + 3);
    if (location is null) {
        writeln("Failed to allocate memory for location.");
        free(video);
        return null;
    }

    sprintf(location, "%s://%s", protocol, src);
    auto media = libvlc_media_new_location(libvlc, location);
    free(location);

    if (media is null) {
        writeln("Failed to create media.");
        free(video);
        return null;
    }

    video.player = libvlc_media_player_new_from_media(media);
    libvlc_media_release(media);

    if (video.player is null) {
        writeln("Failed to create media player.");
        free(video);
        return null;
    }

    video.needUpdate = false;
    video.texW = 0;
    video.texH = 0;
    video.buffer = null;
    video.texture.id = 0;

    libvlc_video_set_callbacks(video.player, &begin_vlc_rendering, &end_vlc_rendering, null, video);
    libvlc_media_player_set_media_player_end_reached_callback(video.player, &videoEndCallback, video);

    return video;
}

void cleanup_video(Video* video) {
    if (video is null) return;

    libvlc_media_player_stop(video.player);
    libvlc_media_player_release(video.player);
    if (video.texture.id != 0) {
        UnloadTexture(video.texture);
    }
    video.mutex.destroy();
    if (video.buffer !is null) {
        MemFree(video.buffer);
    }
    free(video);
}

extern (C) int playVideo(char* argv) {
    const(char)*[] vlcArgs;
    if (!rel) {
        vlcArgs = ["--verbose=2", "--no-xlib", "--drop-late-frames", "--live-caching=0", "--no-lua"];
    } else {
        vlcArgs = ["--verbose=-1", "--no-xlib", "--drop-late-frames", "--live-caching=0", "--no-lua"];
    }
    auto libvlc = libvlc_new(cast(int)vlcArgs.length, cast(const(char)**)vlcArgs.ptr);

    if (libvlc is null) {
        writeln("Something went wrong with libvlc init.\nif you think you can fix it, turn on DEBUG mode in gamefolder/conf/build_type.conf at string BUILD_TYPE to check all available logs");
        videoFinished = true;
        return 0;
    }

    Video*[] video_list;
    auto new_video = add_new_video(libvlc, argv, "file");

    if (new_video is null) {
        libvlc_release(libvlc);
        return 0;
    }

    video_list ~= new_video;
    libvlc_media_player_play(new_video.player);
    if (!rel) writeln("Video started playing");

    while (!WindowShouldClose()) {
        if (videoFinished) {
            break;
        }
        
        BeginDrawing();
        ClearBackground(Colors.BLACK);

        foreach (video; video_list) {
            if (video.buffer is null) {
                if (libvlc_media_player_get_state(video.player) == libvlc_state_t.libvlc_Playing) {
                    libvlc_video_get_size(video.player, 0, &video.texW, &video.texH);

                    if (video.texW > 0 && video.texH > 0) {
                        float screenWidth = cast(float)GetScreenWidth();
                        float screenHeight = cast(float)GetScreenHeight();
                        float videoAspectRatio = cast(float)video.texW / cast(float)video.texH;
                        float screenAspectRatio = screenWidth / screenHeight;

                        if (videoAspectRatio < screenAspectRatio) {
                            video.scale = screenHeight / cast(float)video.texH;
                        } else {
                            video.scale = screenWidth / cast(float)video.texW;
                        }

                        libvlc_video_set_format(video.player, "RV24", video.texW, video.texH, video.texW * 3);

                        video.mutex.lock();
                        video.texture.id = rlLoadTexture(null, video.texW, video.texH, PixelFormat.PIXELFORMAT_UNCOMPRESSED_R8G8B8, 1);
                        video.texture.width = video.texW;
                        video.texture.height = video.texH;
                        video.texture.format = PixelFormat.PIXELFORMAT_UNCOMPRESSED_R8G8B8;
                        video.texture.mipmaps = 1;
                        video.buffer = cast(ubyte*)MemAlloc(video.texW * video.texH * 3);
                        video.needUpdate = false;
                        video.mutex.unlock();

                        if (!rel) writeln("Video texture initialized");
                    }
                }
            } else {
                if (video.needUpdate) {
                    video.mutex.lock();
                    UpdateTexture(video.texture, video.buffer);
                    video.needUpdate = false;
                    video.mutex.unlock();
                }

                Vector2 position = { (GetScreenWidth() - video.texW * video.scale) * 0.5f, (GetScreenHeight() - video.texH * video.scale) * 0.5f };
                DrawTextureEx(video.texture, position, 0, video.scale, Colors.WHITE);
            }
        }

        // Add Skip text/button
        int posY = GetScreenHeight() - 20 - 40;
        if (IsGamepadAvailable(0)) {
            int buttonSize = 30;
            int circleCenterX = 40 + buttonSize / 2;
            int circleCenterY = posY + buttonSize / 2;
            int textYOffset = 7; // Adjust this offset based on your font and text size
            DrawCircle(circleCenterX, circleCenterY, buttonSize / 2, Colors.GREEN);
            DrawText(cast(char*)("A"), circleCenterX - 5, circleCenterY - textYOffset, 20, Colors.BLACK);
            DrawText(cast(char*)(" to skip video"), 40 + buttonSize + 5, posY, 20, Colors.WHITE);
        } else {
            DrawText(cast(char*)("Press Enter to Skip"), 40, posY, 20, Colors.WHITE);
        }

        if (IsKeyPressed(KeyboardKey.KEY_ENTER) || IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) {
            foreach (video; video_list) {
                cleanup_video(video);
            }

            videoFinished = true;
            video_list.length = 0;
            EndDrawing();
            libvlc_release(libvlc);
            return 0;
        }

        EndDrawing();
    }

    foreach (video; video_list) {
        cleanup_video(video);
    }
    videoFinished = true;
    video_list.length = 0;
    libvlc_release(libvlc);
    return 0;
}