function scr_music_quiet(_duration_seconds = 3) {
    var _duration_ms = _duration_seconds * 1000;
    
    // 1. If global.music is valid, fade it directly
    if (variable_global_exists("music") && global.music != noone)
    {
        if (audio_is_playing(global.music))
        {
            var _snd = global.music;
            audio_sound_gain(_snd, 0, _duration_ms);
            
            call_later(_duration_seconds, time_source_units_seconds, method({ _target_snd: _snd }, function() {
                if (audio_is_playing(_target_snd)) {
                    audio_stop_sound(_target_snd);
                }
            }));
        }
    }
    
    // 2. Fallback: If global.song is playing as a sound asset, fade that too
    if (variable_global_exists("song") && audio_is_playing(global.song))
    {
        var _song = global.song;
        audio_sound_gain(_song, 0, _duration_ms);
        
        call_later(_duration_seconds, time_source_units_seconds, method({ _target_song: _song }, function() {
            if (audio_is_playing(_target_song)) {
                audio_stop_sound(_target_song);
            }
        }));
    }
}