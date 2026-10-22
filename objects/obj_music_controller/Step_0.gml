if (global.song != undefined && global.song != noone)
{
    var _time = (current_time - global.song_start) / 1000;
    _time -= global.offset;

    var _beat_length = 60 / 120;

    global.beat = _time / _beat_length;

    // global.song is sometimes a raw sound asset instead of a struct
    // (e.g. obj_cutscenefade, obj_bootstrap) — those loop natively and
    // have no "beats" field, so only run this fallback for real song structs.
    if (is_struct(global.song) && global.beat >= global.song.beats)
    {
        audio_stop_sound(global.music);
        global.music = audio_play_sound(global.song.sound, 1, false, 0);
        audio_sound_gain(global.music, 1, 3000);
        global.song_start = current_time;
    }
}

// Generic seamless looping for any registered track (global.music,
// global.friend_theme, or anything else). Register with scr_song_loop_track().
for (var i = array_length(global.tracked_loops) - 1; i >= 0; i--)
{
    var _loop = global.tracked_loops[i];

    if (!audio_is_playing(_loop.instance))
    {
        array_delete(global.tracked_loops, i, 1);
        continue;
    }

    var _pos = audio_sound_get_track_position(_loop.instance);

    if (_pos >= _loop.loop_end)
    {
        var _buffer  = _pos - _loop.loop_end;
        var _new_pos = _loop.loop_start + _buffer;

        audio_sound_set_track_position(_loop.instance, _new_pos);

        // If this is also the "main" tracked song, keep the beat clock in sync.
        if (_loop.instance == global.music)
        {
            global.song_start = current_time - (_new_pos + global.offset) * 1000;
        }
    }
}