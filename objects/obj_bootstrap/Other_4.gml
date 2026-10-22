display_set_gui_size(camera_get_view_width(view_camera[0]), camera_get_view_height(view_camera[0]));

if (!variable_global_exists("wasd_on")) scr_controls_set(true);

// --- TESTING: which Knight round the fight starts on. 1 = normal, 13 = the last attack, 14 = straight to the ending
// if (!variable_global_exists("knight_start_round")) global.knight_start_round = 13;

// 1. Initialize Globals FIRST before using them anywhere

// Testing Globals

/* if (!variable_global_exists("dialogue_self"))
{
    variable_global_set("dialogue_self", 0);
}
/*
if (!variable_global_exists("king_moved_x"))
{
    global.king_moved_x = 610;
}

if (!variable_global_exists("king_moved_y"))
{
    global.king_moved_y = 235;
}
/*
if (!variable_global_exists("song"))
{
    global.song = sng_empty;
    audio_play_sound(global.song, 1, true);
}

if (!variable_global_exists("dbg_friend_offx"))
{
    global.dbg_friend_offx = -114;
}
if (!variable_global_exists("dbg_friend_offy"))
{
    global.dbg_friend_offy = -72;
}
*/



// General Globals
if (!variable_global_exists("king_moved_x"))
{
    global.king_moved_x = noone; // noone = not set yet; rm_three keeps King's placed position
}

if (!variable_global_exists("king_moved_y"))
{
    global.king_moved_y = noone;
}

if (!variable_global_exists("hide_face"))
{
    global.hide_face = false;
}

if (!variable_global_exists("DEBUG_BARRAGE"))
{
    global.DEBUG_BARRAGE = false;
}

if (!variable_global_exists("fight_attack_active"))
{
    global.fight_attack_active = false;
}

if (!variable_global_exists("fight_seq_starting"))
{
    global.fight_seq_starting = false;
}

if (!variable_global_exists("cutscene_lock"))
{
    global.cutscene_lock = false;
}

if (!variable_global_exists("knight_turning"))
{
    global.knight_turning = false;
}

if (!variable_global_exists("warp_pending"))
{
    global.warp_pending = false;
}

if (!variable_global_exists("fight_seq_ui_done"))
{
    global.fight_seq_ui_done = false;
}

if (!variable_global_exists("ui_sequence_active"))
{
    global.ui_sequence_active = false;
}

if (!variable_global_exists("default_talkbox_dim"))
{
    global.default_talkbox_dim = 0;
}


// 2. Objects Creation
if (!instance_exists(obj_attack_bank))
{
	if instance_exists(obj_mewmew) {
	    instance_create_depth(0, 0, 0, obj_attack_bank);
	}
}

if (!instance_exists(obj_cutscenehandler_midfightattacks))
    instance_create_depth(0, 0, 0, obj_cutscenehandler_midfightattacks);

if (!instance_exists(obj_cutscenefade))
    instance_create_depth(0, 0, 0, obj_cutscenefade);

if (!instance_exists(obj_music_controller))
    instance_create_depth(0, 0, 0, obj_music_controller);

if (!instance_exists(obj_kris))
    instance_create_depth(0, 0, 0, obj_kris);

if (!instance_exists(obj_dial_invis))
    instance_create_depth(0, 0, 0, obj_dial_invis);

if (!instance_exists(obj_talkbox_dialogue))
    instance_create_depth(0, 0, 0, obj_talkbox_dialogue);

if (!instance_exists(obj_camera_controller))
    instance_create_depth(0, 0, 0, obj_camera_controller);

if (!instance_exists(obj_lighting))
    instance_create_depth(0, 0, 0, obj_lighting);
	
	

/*
// 3. Variables & Spawning Fighters Safely
scr_set_dim_left(.75);
scr_set_dim_right(.75);

// Better yet: set these flags in the objects' Create Events instead, 
// but if doing it here, ensure they exist first:
var _gerson = instance_create_layer(0, 0, "Instances", obj_gerson);
var _mewmew = instance_create_layer(0, 0, "Instances", obj_mewmew);
var _spamton = instance_create_layer(0, 0, "Instances", obj_spamton);
var _jevil = instance_create_layer(0, 0, "Instances", obj_jevil);

if (instance_exists(_mewmew)) _mewmew.light_on = true;
if (instance_exists(_jevil)) _jevil.light_on = true;
if (instance_exists(_spamton)) _spamton.light_on = true;
if (instance_exists(_gerson)) 
{
    _gerson.lantern_on = true;
    _gerson.light_on = true;
}

*/

// 4. Room music

// sng_knightappear from the very start, until the battle starts (only the first time: rm_zero's revisited for the ending)
if (room == rm_zero && !variable_global_exists("knight_appear_started"))
{
    global.knight_appear_started = true;
    with (obj_cutscenefade) old_music_faded = true; // the room's opening fader would otherwise fade it right back out
    start_knight_appear_music(2000);
}

/* Lancer's song in the cafe
if (room == rm_zero && !audio_is_playing(sng_LCP))
{
    // the room's opening fader would otherwise fade this out right away
    with (obj_cutscenefade) old_music_faded = true;

    global.music = scr_audio_fade_in(sng_LCP, 2000, 1, true); // 2s fade in, looping
    global.song = sng_LCP;
    global.song_start = current_time;
}