// the Titan battle at the top of the tower: Susie, Ralsei & Queen in the middle, King + Lancer on the left, the Titan
// on the right. obj_tower_top_scene calls scr_titan_battle_start() once King's laughed.
//  - the party faces whoever they're aiming at (left for King / Lancer, right for the Titan)
//  - before the first turn, Susie: "This game is OVER!" and the TP bar shatters (everything's free from then on)
//  - picking Lancer to attack: Susie stops it ("We are NOT attacking him." "...yet.") and Rude Busters his row away

// --- tuning ---
global.titan_battle_song = sng_chaosguardian;

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
        // the enemy turns: { talk: [ TALKbox lines ], attack }. once they've all played it keeps repeating from rounds_loop_from
        rounds = [
            { talk: scr_titan_round1_talk(), attack: scr_start_titan_attack1 },
            // TODO: the next turns. for now it's attack 1 again (no talk), with Lancer back to his normal sprite
            { talk: [ { run: function() { with (obj_lancer) { sprite_index = spr_lancer_battle; image_index = 0; } } } ],
              attack: scr_start_titan_attack1 },
        ];
        rounds_loop_from = 1;

        // after attack 1: the first time Susie goes to FIGHT, "I take it back.", and Lancer's row comes back
        takeback_done = false;
        fight_hook = function(_who)
        {
            if (_who != 0 || turn < 1 || takeback_done) return false;
            takeback_done = true;
            start_script([
                { say: { spr: spr_susie_dialogue, img: 17, text: "* I take it back." } },
                { list: true },
                // (a function written inside a { } belongs to that struct, not the menu: so it names the menu outright)
                { run: function()
                    {
                        with (obj_battle_menu)
                        {
                            protect_target = noone;   // she won't stop anyone now
                            var _menu = id;
                            with (obj_battle_target) if (kind == "lancer") _menu.rebuild_row(id);
                        }
                        with (obj_lancer) { sprite_index = spr_lancer_battle_hurt; image_index = 0; }   // shocked
                    } },
                { wait: 50 },
                { talk: [ { speaker: obj_lancer, text: "S-Susie...?" } ] },
                { wait: 20 },
            ], function() { state = "choose"; t = 0; });   // (straight back to picking her target: still on FIGHT)
            return true;
        };
        flavor = [
            "* The Castle Top is covered in darkness.",
            "* King's spades glint in the dark.",
            "* Lancer seems to be in a heavy self-internal struggle.",
            "* Ralsei is still thinking of a plan.",
            "* Defending seems like a good idea.",
        ];
        facing_enabled = true;
        auto_mouth     = true;   // everyone's bubbles go in front of their mouths
        default_facing = -1;   // toward King and Lancer to start with

        // "This game is OVER!": as she says it she Rude Busters the TP bar, and it breaks
        intro_lines = [
            { spr: spr_susie_dialogue, img: 17, text: "* This game is OVER!",
              on_start: function() { with (obj_battle_menu) start_buster(tp_bar_target(), scr_tp_break); } },
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

        // as the UI comes in, everyone drops out of their ready poses into their battle idles (facing King + Lancer)
        for (var i = 0; i < 3; i++)
        {
            if (defs[i] == undefined) continue;
            scr_bm_idle(defs[i]);
            face_member(i, default_facing);
        }
    }
}


/// attack 1: Titan Spawn attack 1, with King's spades flying through the box (obj_titan_attack1)
function scr_start_titan_attack1()
{
    var _d = instance_exists(obj_battlebox) ? obj_battlebox.depth - 1 : -5001;
    return instance_create_depth(0, 0, _d, obj_titan_attack1);
}

/// the enemy turn before attack 1 (TALKbox lines). King faces right in this fight, so his bubbles go on his right
function scr_titan_round1_talk()
{
    var _king = { offx: 10, offy: 50, flip: true };   // (from his x, mirrored: just in front of his face)
    return [
        { speaker: obj_susie,  text: "I thought you were my friend, Lancer..." },
        { speaker: obj_lancer, text: "I am, Susie! I just..." },
        { speaker: obj_susie,  text: "Shut up." },
        { speaker: obj_lancer, text: "..." },
        { speaker: obj_king,   text: "Do not disrespect my son, Lightner." },
        { speaker: obj_susie,  text: "You gonna try kicking our asses again?" },
        { speaker: obj_susie,  text: "Good luck with that." },
        { speaker: obj_king,   text: "Who said I need to do anything?" },
        { speaker: obj_susie,  text: "..." },
        { speaker: obj_susie,  text: "Lancer, you better no", instant_cutoff: true },   // cut off by...
        // ...a spade from King, straight at her, really fast. she guards just in time
        { run: function() { with (obj_tower_top_scene) battle_spade_at_susie(); },
          wait_until: function() { return !instance_exists(obj_tower_top_scene) || obj_tower_top_scene.battle_spade_done; },
          wait: 20 },
        { speaker: obj_lancer, text: "Susie, I..." },
        { speaker: obj_susie,  text: "..." },
    ];
}