var _bpm = 130;
var _song_pos = audio_sound_get_track_position(global.music);
var _total_frames = sprite_get_number(sprite_index); // use current sprite not hardcoded
image_index = (_song_pos / (60 / _bpm) * _total_frames / 2) mod _total_frames;