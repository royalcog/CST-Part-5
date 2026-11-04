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

    // the music, as it'd be at that point: everything that was playing stops (the scenes that would've cut it off
    // aren't coming), then the climb's song if it'd still be going (it plays until the Titan Spawn land). by the
    // Titan reveal the Titan Spawn battle's song has already ended: silence
    scr_debug_music_reset();
    if (!_to_titan)
    {
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
    scr_debug_music_reset();   // (silence: the battle starts its own song)
    room_goto(rm_tower_top);   // (restarts it if you're already there)
}

/// every sound stops, and nothing's "the song" (so nothing carries over from where you skipped from)
function scr_debug_music_reset()
{
    audio_stop_all();
    global.music = noone;
    global.song  = noone;
}