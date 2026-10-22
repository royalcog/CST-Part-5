function start_walking_music()
{
    if (variable_global_exists("song") && global.song != noone && global.song != undefined && is_struct(global.song))
    {
        if (global.song.sound == sng_empty) exit;
    }
    global.song = {
        sound: sng_empty,
        beats: 224
    };
    global.music = audio_play_sound(global.song.sound, 1, false, 0);
    audio_sound_gain(global.music, 1.2, 3000);
    global.song_start = current_time;
}

function scr_song_loop_track(_sound_instance, _loop_start, _loop_end)
{
    array_push(global.tracked_loops, {
        instance: _sound_instance,
        loop_start: _loop_start,
        loop_end: _loop_end
    });
}

function start_battle_music()
{
    if (variable_global_exists("song") && global.song != noone && global.song != undefined && is_struct(global.song))
    {
        if (global.song.sound == sng_kingofchaos) exit;
    }
    global.song = {
        sound: sng_kingofchaos,
        beats: 9999
    };
    
    global.music = audio_play_sound(global.song.sound, 2, true, 1.3);
    audio_sound_gain(global.music, 1, 0);
    global.song_start = current_time;
}

/// _fade_ms = 0 starts at full volume; anything higher fades in over that long
function start_knight_battle_music(_fade_ms = 0)
{
    if (variable_global_exists("song") && is_struct(global.song) && global.song.sound == sng_blackaxe) exit;
    global.song = {
        sound: sng_blackaxe,
        beats: 9999
    };
    global.music = audio_play_sound(global.song.sound, 2, true, (_fade_ms > 0) ? 0 : 1);
    if (_fade_ms > 0) audio_sound_gain(global.music, 1, _fade_ms);
    global.song_start = current_time;
}

/// sng_knightappear, fading in and looping (the lead-up before the battle, and in rm_two before the Titan)
function start_knight_appear_music(_fade_ms = 2000)
{
    if (variable_global_exists("song") && is_struct(global.song) && global.song.sound == sng_knightappear) exit;
    global.song = { sound: sng_knightappear, beats: 9999 };
    global.music = scr_audio_fade_in(sng_knightappear, _fade_ms, 1, true);
    global.song_start = current_time;
}

/// fades sng_knightappear out (and stops it) if it's what's playing
function stop_knight_appear_music(_fade_ms = 1000)
{
    if (!variable_global_exists("song") || !is_struct(global.song) || global.song.sound != sng_knightappear) exit;
    var _inst = global.music;
    global.song  = noone;
    global.music = noone;
    if (_inst == noone) exit;
    if (_fade_ms <= 0) { audio_stop_sound(_inst); exit; }
    audio_sound_gain(_inst, 0, _fade_ms);
    scr_call_after_frames(method({ inst: _inst }, function() { audio_stop_sound(inst); }), ceil(_fade_ms / 1000 * game_get_speed(gamespeed_fps)));
}

function scr_ui_reverse(_resume_sound, _resume_pitch = 1, _sprite_obj = noone, _sprite = noone, _sprite_loop = false, _sprite_image = 0)
{
    if (instance_exists(obj_UI))
    {
        obj_UI.target_x = obj_UI.offscreen_x;
    }
    audio_stop_all();
    global.song = { sound: _resume_sound, beats: 9999 };
    global.music = audio_play_sound(_resume_sound, 1, true);
    audio_sound_pitch(global.music, _resume_pitch);
    global.song_start = current_time;

    if (_sprite_obj != noone && instance_exists(_sprite_obj))
    {
        _sprite_obj.sprite_index = _sprite;
        _sprite_obj.image_index = 0;
        _sprite_obj.image_speed = _sprite_loop ? 1 : 0;
        _sprite_obj.anim_loop = _sprite_loop;
    }
}

function scr_audio_fade_out(_sound_inst, _duration_ms, _stop_after = true, _stop_delay_frames = noone)
{
    audio_sound_gain(_sound_inst, 0, _duration_ms);

    if (_stop_after)
    {
        var _delay = (_stop_delay_frames != noone) ? _stop_delay_frames : (_duration_ms / 1000 * game_get_speed(gamespeed_fps));
        if (instance_exists(obj_cutscenehandler_midfightattacks))
        {
            array_push(obj_cutscenehandler_midfightattacks.after_textbox_delayed_queue, {
                is_sound_stop: true,
                sound_inst: _sound_inst,
                delay: _delay
            });
        }
    }
}

/// plays a sound starting silent and fades it up to _gain over _duration_ms
/// returns the sound instance so you can stop/fade it out later
function scr_audio_fade_in(_snd, _duration_ms, _gain = 1, _loop = false, _priority = 1)
{
    var _inst = audio_play_sound(_snd, _priority, _loop, 0);
    audio_sound_gain(_inst, _gain, _duration_ms);
    return _inst;
}