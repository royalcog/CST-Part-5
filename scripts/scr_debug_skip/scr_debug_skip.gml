/// debug: jump straight to the top of the tower (rm_tower_top), as if you'd just climbed off the top of rm_tower2.
/// _to_battle: also skip the talk up there and go straight into "Let's end this." -> the Titan Spawn battle
function scr_debug_skip_to_tower_top(_to_battle = false)
{
    global.plat_hp           = { susie: 290, ralsei: 210 };   // full HP, like after the heal
    global.plat_lock         = false;
    global.cutscene_lock     = false;
    global.debug_skip_battle = _to_battle;                     // obj_tower_top_scene checks this

    // anything mid-way through closes
    with (obj_textbox) instance_destroy();
    with (obj_cutscenefade) instance_destroy();

    // the climb's song (it keeps going up there until the Titan Spawn land)
    if (!(variable_global_exists("song") && global.song == sng_chaostower))
    {
        if (variable_global_exists("music")) audio_stop_sound(global.music);
        global.music = audio_play_sound(sng_chaostower, 2, true);
        global.song  = sng_chaostower;
    }

    room_goto(rm_tower_top);   // (restarts it if you're already there)
}