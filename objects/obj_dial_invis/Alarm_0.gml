// audio_sound_gain(global.music, 0);
obj_cutscenehandler_midfightattacks.dess_attack_state = 1;

if instance_exists(obj_cutscenehandler_midfightattacks)
{
    var _ch = obj_cutscenehandler_midfightattacks;
    if _ch.cutoff_callback == "impact_sequence"
    {
        _ch.impact_seq_state = 1;
        _ch.cutoff_callback = noone;
    }
}