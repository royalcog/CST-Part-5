/// true once every party member is swooned
function scr_party_all_down()
{
    if (instance_number(obj_battle_ui_box) == 0) return false;
    var _all = true;
    with (obj_battle_ui_box) if (hp > 0) _all = false;
    return _all;
}

/// stops the fight where it stands: attacks, bullets, dialogue, soul, box, UI, music
function scr_battle_wipe_cleanup(_music_fade_ms = 600)
{
    var _objs = [
        obj_knight_sword_attack, obj_knight_split_attack, obj_knight_starchild_attack,
        obj_knight_maze_attack, obj_knight_lightblue_attack, obj_knight_gridturn_attack,
        obj_knight_susiewall_attack, obj_knight_switch_attack, obj_knight_shatter_attack, obj_knight_shield_attack,
        obj_knight_prism_attack, obj_knight_echo_attack, obj_knight_last_attack, obj_knight_lane_sword, obj_susie_barrier, obj_rude_buster,
        obj_dialogue_chain, obj_talkbox
    ];
    for (var i = 0; i < array_length(_objs); i++)
    {
        with (_objs[i]) instance_destroy();
    }

    with (obj_soul) instance_destroy();
    with (obj_battlebox) instance_destroy();

    if (instance_exists(obj_UI)) obj_UI.target_x = obj_UI.offscreen_x;
    if (global.music != noone) audio_sound_gain(global.music, 0, _music_fade_ms);
}

/// what happens after the Knight swoons everyone — fill this in once it's built
function scr_knight_party_wiped()
{
    show_debug_message("Knight fight: party wiped (next scene goes here)");
}