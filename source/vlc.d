module vlc;

extern (C) {
    struct libvlc_instance_t;
    struct libvlc_media_t;
    struct libvlc_media_player_t;
    struct libvlc_event_manager_t;
    struct libvlc_event_t;

    libvlc_instance_t* libvlc_new(int argc, const(char)** argv);
    void libvlc_release(libvlc_instance_t* instance);

    libvlc_media_t* libvlc_media_new_location(libvlc_instance_t* instance, const(char)* mrl);
    void libvlc_media_release(libvlc_media_t* media);

    libvlc_media_player_t* libvlc_media_player_new_from_media(libvlc_media_t* media);
    void libvlc_media_player_release(libvlc_media_player_t* player);
    void libvlc_media_player_play(libvlc_media_player_t* player);
    void libvlc_media_player_stop(libvlc_media_player_t* player);
    int libvlc_media_player_get_state(libvlc_media_player_t* player);

    void libvlc_video_set_callbacks(libvlc_media_player_t* player, 
                                    void* function(void*, void**), 
                                    void function(void*, void*, void*), 
                                    void* function(void*), 
                                    void* opaque);

    void libvlc_video_set_format(libvlc_media_player_t* player, 
                                 const(char)* chroma, 
                                 uint width, 
                                 uint height, 
                                 uint pitch);

    void libvlc_video_get_size(libvlc_media_player_t* player, 
                               uint num, 
                               uint* px, 
                               uint* py);

    libvlc_event_manager_t* libvlc_media_player_event_manager(libvlc_media_player_t* player);
    void libvlc_event_attach(libvlc_event_manager_t* event_manager, 
                            int event_type, 
                            void function(const(libvlc_event_t)*, void*), 
                            void* user_data);
    int libvlc_event_detach(libvlc_event_manager_t* event_manager, 
                            int event_type, 
                            void function(const(libvlc_event_t)*, void*), 
                            void* user_data);
}

enum libvlc_state_t {
    libvlc_NothingSpecial = 0,
    libvlc_Opening,
    libvlc_Buffering,
    libvlc_Playing,
    libvlc_Paused,
    libvlc_Stopped,
    libvlc_Ended,
    libvlc_Error
}

enum libvlc_event_type_t {
    libvlc_MediaPlayerEndReached = 256
}

extern (C) void endReachedCallback(const(libvlc_event_t)* event, void* user_data) {
    auto callback = cast(void function(void*))user_data;
    callback(user_data);
}

extern (C) void libvlc_media_player_set_media_player_end_reached_callback(libvlc_media_player_t* player, 
void function(void*), void* user_data) {
    auto event_manager = libvlc_media_player_event_manager(player);
    libvlc_event_attach(event_manager, libvlc_event_type_t.libvlc_MediaPlayerEndReached, &endReachedCallback, 
    cast(void*)user_data);
}
