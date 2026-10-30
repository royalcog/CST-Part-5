// the Titan battle at the top of the tower: Susie, Ralsei & Queen in the middle, King + Lancer on the left, the Titan
// on the right. obj_tower_top_scene calls scr_titan_battle_start() once King's laughed.
//  - the party faces whoever they're aiming at (left for King / Lancer, right for the Titan)
//  - before the first turn, Susie: "This game is OVER!" and the TP bar shatters (everything's free from then on)
//  - picking Lancer to attack: Susie stops it ("We are NOT attacking him." "...yet.") and Rude Busters his row away

// --- tuning ---
global.titan_battle_song = sng_kingofchaos;   // swap for the fight's own song

/// a battle enemy standing in for _body (obj_battle_target). _cfg's fields go straight onto it
function scr_battle_target_make(_body, _cfg)
{
    var _b = instance_find(_body, 0);
    if (_b == noone) return noone;
    var _t = instance_create_depth(_b.x, _b.y, _b.depth - 1, obj_battle_target);
    _t.body = _b;
    var _keys = variable_struct_get_names(_cfg);
    for (var i = 0; i < array_length(_keys); i++) variable_instance_set(_t, _keys[i], _cfg[$ _keys[i]]);
    _t.hp = _t.max_hp;
    with (_t) follow();
    return _t;
}

/// the battle starts: UI + party boxes in, the TP bar in (darkness), music, the three targets, the menu
function scr_titan_battle_start()
{
    with (obj_UI) instance_destroy();
    instance_create_depth(0, 0, -100, obj_UI);
    scr_party_init_trio();   // their full HP (Ralsei just healed everyone)
    global.soul_glow_radius = 48;

    // centre the three boxes on the screen, the purple/black panel across the whole width (same as the Titan Spawn fight)
    var _cam_cx = camera_get_view_x(view_camera[0]) + camera_get_view_width(view_camera[0]) / 2;
    var _left   = obj_UI.target_x + (-1)  + obj_UI.boxes_x_correction;
    var _right  = obj_UI.target_x + 460   + obj_UI.boxes_x_correction + sprite_get_width(spr_queenbox_empty) * (52 / 47);
    var _shift  = _cam_cx - (_left + _right) / 2;
    obj_UI.target_x   += _shift;
    obj_UI.onscreen_x += _shift;
    obj_UI.panel_full_width = true;
    obj_UI.depth = -10002;
    with (obj_battle_ui_box) depth = -10003;

    scr_tp_reset(true);
    scr_tp_bar_show(true);

    // the music
    if (variable_global_exists("music")) audio_stop_sound(global.music);
    global.song  = { sound: global.titan_battle_song, beats: 9999 };
    global.music = audio_play_sound(global.titan_battle_song, 2, true, 1);
    global.song_start = current_time;

    // the targets, top to bottom in the list: King, Lancer, the Titan
    with (obj_battle_target) instance_destroy();
    var _king = scr_battle_target_make(obj_king, {
        kind: "king", enemy_name: "King", side: -1, home_y: 0,
        max_hp: 3000, at: 18, df: 0, rudebuster_mult: 1,   // Rude Buster hits him like normal
        check_text: "* KING - AT 18 DF 0\n* Back at full power. Fight for the throne."
    });
    var _lancer = scr_battle_target_make(obj_lancer, {
        kind: "lancer", enemy_name: "Lancer", side: -1, home_y: 1,
        max_hp: 400, at: 3, df: 0, rudebuster_mult: 1,
        check_text: "* LANCER - AT 3 DF 0\n* He won't look at you."
    });
    var _titan = scr_battle_target_make(obj_titan_reveal, {
        kind: "titan", enemy_name: "Titan", side: 1, home_y: 2,
        max_hp: 6000, at: 40, df: 0, rudebuster_mult: 0.5,  // it shrugs most of Rude Buster off (like the Titan Spawn)
        check_text: "* TITAN - AT 40 DF 800\n* The fear of dark, which appears in many forms."
    });

    // the menu
    with (obj_battle_menu) instance_destroy();
    with (instance_create_depth(0, 0, -10050, obj_battle_menu))
    {
        // TODO: King / the Titan's turns go here, one per enemy turn (they loop):
        //   { talk: [ { speaker: obj_king, text: "..." } ], attack: scr_start_... }
        rounds = [];
        flavor = [
            "* The Titan looms behind you.",
            "* King's spades glint in the dark.",
            "* Lancer won't look at you.",
            "* Ralsei is still thinking of a plan.",
            "* Defending seems like a good idea.",
        ];
        facing_enabled = true;
        default_facing = -1;   // toward King and Lancer at the start of each turn

        // "This game is OVER!": the TP bar breaks as she says it
        intro_lines = [
            { spr: spr_susie_dialogue, img: 17, text: "* This game is OVER!", on_start: scr_tp_break },
        ];
        state = "intro_say";
        t = 0;

        // picking Lancer to attack
        protect_target = _lancer;
        protect_lines  = [
            { spr: spr_susie_dialogue, img: 17, text: "* We are NOT attacking him." },
            { spr: spr_susie_dialogue, img: 34, text: "* ...yet." },
        ];
        on_win = undefined;
    }
}