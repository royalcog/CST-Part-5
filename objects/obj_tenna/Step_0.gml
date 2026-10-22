if !anim_loop && image_index >= image_number - 1
{
    image_speed = 0;
    image_index = image_number - 1;
}
scr_char_jolt_update(self);

if !use_battle_ext && sprite_index == spr_tenna_dance_cabbage
{
    var _bpm = 130;
    var _song_pos = audio_sound_get_track_position(global.music);
    var _total_frames = 93;
    image_index = ((_song_pos / (60 / _bpm) * _total_frames / 4) + 11) mod _total_frames;
    image_speed = 0;
}

switch (face_phase)
{
    case 0:
        face_timer++;
        if face_timer >= 120
        {
            face_timer = 0;
            face_phase = 1;
        }
    break;
    case 1:
        face_frame -= 0.15;
        if face_frame <= 0
        {
            face_frame = 0;
            face_timer = 0;
            face_phase = 2;
        }
    break;
    case 2:
        face_timer++;
        if face_timer >= 30
        {
            face_timer = 0;
            face_phase = 3;
        }
    break;
    case 3:
        face_frame += 0.15;
        if face_frame >= 2
        {
            face_frame = 2;
            face_timer = 0;
            face_phase = 0;
        }
    break;
}

if (active == 0)
    exit;
if (active == 1)
{
    timer++;
}