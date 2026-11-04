/// debug: jump straight to the top of the tower (rm_tower_top), as if you'd just climbed off the top of rm_tower2.
/// _to_battle: also skip the talk up there and go straight into "Let's end this." -> the Titan Spawn battle
/// _to_titan: skip the battle and the talk after it too, straight to the Titan reveal
function scr_debug_skip_to_tower_top(_to_battle = false, _to_titan = false)
{
    global.plat_hp           = { susie: 290, ralsei: 210 };   // full HP, like after the heal
    global.plat_lock         = false;
    global.cutscene_lock     = false;
    global.debug_skip_battle = _to_battle;                     // obj_tower_top_scene checks this
    global.debug_skip_titan  = _to_titan;                      // (and this)

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

/// debug (F8): straight into the second Titan battle (Ralsei & Queen, after the flashback): King sitting behind Queen's
/// shield, Susie gone, everyone's HP where the first battle would've left it
function scr_debug_skip_to_titan2()
{
    global.debug_skip_titan2 = true;                      // obj_tower_top_scene checks this
    global.post_battle_hp = { Susie: { hp: 290, max_hp: 290 }, Ralsei: { hp: 210, max_hp: 210 }, Queen: { hp: 1510, max_hp: 1510 } };
    global.titan_fight_hp = { titan: 6000, king: 1 };
    global.plat_lock      = false;
    global.cutscene_lock  = true;
    with (obj_textbox) instance_destroy();
    with (obj_cutscenefade) instance_destroy();
    if (variable_global_exists("music")) audio_stop_sound(global.music);
    room_goto(rm_tower_top);   // (restarts it if you're already there)
}