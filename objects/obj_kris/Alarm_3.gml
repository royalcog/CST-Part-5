if (instance_exists(obj_UI) && !obj_UI.use_party_boxes)
{
    instance_destroy(obj_UI);
    instance_create_depth(0, 0, -100000000, obj_UI);
    audio_sound_pitch(sng_cmmm, 2);
    music_started = true;
}