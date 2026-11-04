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
    obj_UI.follow_cam = true;   // (the camera pans in turn 3: the boxes stay put on the screen)
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
            { talk: scr_titan_round2_talk(), attack: scr_start_titan_attack2 },
            { talk: scr_titan_round3_talk(), attack: scr_start_titan_attack3 },   // (ends the battle)
        ];
        rounds_loop_from = 2;

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
                { talk: [ { speaker: obj_lancer, text: "S-Susie...?", to: obj_susie } ] },
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
        first_flavor = "* The Castle Top is covered in darkness.";
        facing_enabled = true;
        susie_rescue   = true;   // anyone below 20% HP: Susie heals everyone to full
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

/// attack 2: Titan Spawn attack 3, with King's spade bombs flying in from the sides instead of the dashing fish
/// (obj_titan_attack2)
function scr_start_titan_attack2()
{
    var _d = instance_exists(obj_battlebox) ? obj_battlebox.depth - 1 : -5001;
    return instance_create_depth(0, 0, _d, obj_titan_attack2);
}

/// attack 3: Susie snaps. it's a whole scene, and it ends the battle (obj_titan_attack3)
function scr_start_titan_attack3()
{
    var _d = instance_exists(obj_battlebox) ? obj_battlebox.depth - 1 : -5001;
    return instance_create_depth(0, 0, _d, obj_titan_attack3);
}

/// the enemy turn before attack 1 (TALKbox lines). King faces right in this fight, so his bubbles go on his right
function scr_titan_round1_talk()
{
    var _king = { offx: 10, offy: 50, flip: true };   // (from his x, mirrored: just in front of his face)
    return [
        { speaker: obj_susie,  text: "I thought you were my friend, Lancer...", to: obj_lancer },
        { speaker: obj_lancer, text: "I am, Susie! I just...", to: obj_susie },
        { speaker: obj_susie,  text: "Shut up.", to: obj_lancer },
        { speaker: obj_lancer, text: "...", to: obj_susie },
        { speaker: obj_king,   text: "Do not disrespect my son, Lightner.", to: obj_susie },
        { speaker: obj_susie,  text: "You gonna try kicking our asses again?", to: obj_king },
        { speaker: obj_susie,  text: "Good luck with that.", to: obj_king },
        { speaker: obj_king,   text: "Who said I need to do anything?", to: obj_susie },
        { speaker: obj_susie,  text: "...", to: obj_king },
        { speaker: obj_susie,  text: "Lancer, you better no", instant_cutoff: true, to: obj_lancer },   // cut off by...
        // ...a spade from King, straight at her, really fast. she guards just in time
        { run: function() { with (obj_tower_top_scene) battle_spade_at_susie(); },
          wait_until: function() { return !instance_exists(obj_tower_top_scene) || obj_tower_top_scene.battle_spade_done; },
          wait: 20 },
        { speaker: obj_lancer, text: "Susie, I...", to: obj_susie },
        { speaker: obj_susie,  text: "...", to: obj_lancer },
    ];
}

/// the enemy turn before attack 2 (TALKbox lines)
function scr_titan_round2_talk()
{
    return [
        // (Lancer's back to his normal sprite, if he was still shocked from "I take it back.")
        { run: function() { with (obj_lancer) { sprite_index = spr_lancer_battle; image_index = 0; } } },
        { speaker: obj_queen,  text: "You Do Understand That What You're Doing Here Is Insane", to: obj_king },
        { speaker: obj_king,   text: "You didn't even know about the Roaring until recently.", to: obj_queen },
        { speaker: obj_king,   text: "What kind of \"villain\" are you?", to: obj_queen },
        { speaker: obj_queen,  text: "One That Sees The Strength Of These Heroes", to: obj_king },
        { speaker: obj_queen,  text: "And The Idiocy Of You And Your \"Team\"", to: obj_king },
        { speaker: obj_lancer, text: "Girldad...?", to: obj_queen },
        { speaker: obj_queen,  text: "...", to: obj_lancer },
    ];
}

/// the enemy turn before attack 3 (TALKbox lines)
function scr_titan_round3_talk()
{
    return [
        { speaker: obj_lancer, text: "Dad, do we really have to", instant_cutoff: true, to: obj_king },   // cut off by...
        { speaker: obj_king,   text: "Yes. We do.", to: obj_lancer },
        { speaker: obj_king,   text: "Please don't make this harder on us as it is with self-doubt.", to: obj_lancer },
        { speaker: obj_susie,  text: "Lancer, he doesn't even care about you! Why are you still siding with him???", to: obj_lancer },
        { speaker: obj_king,   text: "He has come to realize the importance of what the Roaring would mean for us.", to: obj_susie },
        { speaker: obj_queen,  text: "Why Are You Talking For Him", to: obj_king },
        { speaker: obj_king,   text: "Isn't that what you think, Lancer?", to: obj_lancer },
        { speaker: obj_lancer, text: "...", to: obj_king },
        { speaker: obj_king,   text: "...", to: obj_lancer },
        { speaker: obj_king,   text: "Lancer.", to: obj_lancer },
        { speaker: obj_lancer, text: "Yes, Dad.", to: obj_king },
        { speaker: obj_king,   text: "Good.", to: obj_lancer },
        { speaker: obj_susie,  text: "...", to: obj_king },
    ];
}

global.titan_battle2_song = sng_chaosguardian;

/// the second Titan battle (Susie's gone): Ralsei & Queen against the Titan, Ralsei in his serious sprites.
/// one enemy turn (attack 4), then it ends and obj_ralsei_rage.after_battle() takes over
function scr_titan_battle2_start()
{
    // (where King & Lancer ended up after Susie's scene and the flashback: the F8 debug skip puts them back there)
    if (!(variable_global_exists("debug_titan2_skip") && global.debug_titan2_skip))
    {
        ini_open("debug_skip.ini");
        with (obj_king)   { var _kf = scr_get_feet(id); ini_write_real("titan2", "king_x", _kf.x); ini_write_real("titan2", "king_y", _kf.y); }
        with (obj_lancer) { var _lf = scr_get_feet(id); ini_write_real("titan2", "lancer_x", _lf.x); ini_write_real("titan2", "lancer_y", _lf.y); ini_write_real("titan2", "lancer_xs", image_xscale); }
        ini_close();
    }
    global.debug_titan2_skip = false;
    with (obj_UI) instance_destroy();
    instance_create_depth(0, 0, -100, obj_UI);

    // their HP from where the last battle left off
    var _rhp = 210, _qhp = 1510;
    if (variable_global_exists("post_battle_hp"))
    {
        var _p = global.post_battle_hp;
        if (variable_struct_exists(_p, "Ralsei")) _rhp = max(1, _p.Ralsei.hp);
        if (variable_struct_exists(_p, "Queen"))  _qhp = max(1, _p.Queen.hp);
    }
    scr_party_init_trio(1, _rhp, _qhp);
    var _ralsei_box = noone;
    with (obj_battle_ui_box)
    {
        if (char_name == "Susie") instance_destroy();
        else if (char_name == "Ralsei") { body_idle_sprite = spr_ralsei_battle_idle_mad; _ralsei_box = id; cant_die = true; }
    }
    obj_UI.active_box = _ralsei_box;

    // centre the two boxes (Ralsei's middle slot + Queen's) on the screen
    var _cam_cx = camera_get_view_x(view_camera[0]) + camera_get_view_width(view_camera[0]) / 2;
    var _qw     = sprite_get_width(spr_queenbox_empty) * (52 / 47);
    var _left   = obj_UI.target_x + 236 + obj_UI.boxes_x_correction;
    var _right  = obj_UI.target_x + 460 + obj_UI.boxes_x_correction + _qw;
    var _shift  = _cam_cx - (_left + _right) / 2;
    // (where the 3-box battle put them: the panel's text stays there)
    var _shift3 = _cam_cx - ((obj_UI.target_x - 1 + obj_UI.boxes_x_correction) + _right) / 2;
    var _panel_ox = _shift3 - _shift;
    obj_UI.target_x   += _shift;
    obj_UI.onscreen_x += _shift;
    obj_UI.panel_full_width = true;
    obj_UI.follow_cam = true;
    obj_UI.depth = -10002;
    with (obj_battle_ui_box) depth = -10003;

    // the TP bar's still broken (everything's free), so no bar
    scr_tp_init();
    global.tp.broken = true;

    if (variable_global_exists("music")) audio_stop_sound(global.music);
    global.song  = { sound: global.titan_battle2_song, beats: 9999 };
    global.music = audio_play_sound(global.titan_battle2_song, 2, true, 1);
    global.song_start = current_time;

    // just the Titan this time
    with (obj_battle_target) instance_destroy();
    var _titan = scr_battle_target_make(obj_titan_reveal, {
        kind: "titan", enemy_name: "Titan", side: 1, home_y: 0,
        max_hp: 6000, at: 40, df: 0, rudebuster_mult: 0.5,
        check_text: "* TITAN - AT 40 DF 800\n* The fear of dark, which appears in many forms."
    });
    if (_titan != noone && variable_global_exists("titan_fight_hp") && variable_struct_exists(global.titan_fight_hp, "titan"))
        _titan.hp = max(1, global.titan_fight_hp.titan);

    with (obj_battle_menu) instance_destroy();
    with (instance_create_depth(0, 0, -10050, obj_battle_menu))
    {
        // no Susie
        defs[0]    = undefined;
        members[0] = noone;
        // Ralsei's serious sprites for this one
        defs[1].idle        = spr_ralsei_battle_idle_mad;
        defs[1].ready_fight = spr_ralsei_attack_ready_serious;
        defs[1].attack      = spr_ralsei_attack_serious;
        defs[1].defend      = spr_ralsei_defend_serious;

        rounds = [
            { talk: [], attack: scr_start_titan_attack4 },
            { talk: [], attack: scr_start_titan_attack5 },
        ];
        rounds_loop_from = 1;
        // after each enemy turn obj_ralsei_rage takes over (attack 4: the stat boost, attack 5: everything after)
        turn_end_hook = function(_turn) { var _r = false; with (obj_ralsei_rage) _r = on_turn_end(_turn); return _r; };
        panel_ox = _panel_ox;
        flavor = [
            "* The Titan looms over Castle Town",
            "* Ralsei's eyes burn.",
            "* Queen keeps one eye on King.",
        ];
        first_flavor = "* Ralsei's eyes burn.";
        facing_enabled = true;
        default_facing = 1;      // at the Titan
        susie_rescue   = false;
        auto_mouth     = true;
        protect_target = noone;

        for (var i = 0; i < 3; i++)
        {
            if (defs[i] == undefined) continue;
            scr_bm_idle(defs[i]);
            face_member(i, default_facing);
        }
    }
}

/// attack 4: the Ch4 Titan's hands, turning the box as they go (obj_titan_attack4)
function scr_start_titan_attack4()
{
    var _d = instance_exists(obj_battlebox) ? obj_battlebox.depth - 1 : -5001;
    return instance_create_depth(0, 0, _d, obj_titan_attack4);
}

/// attack 5: Titan Spawn attack 1 again, twice as long; halfway, the box breaks and it goes whole-screen (obj_titan_attack5)
function scr_start_titan_attack5()
{
    var _d = instance_exists(obj_battlebox) ? obj_battlebox.depth - 1 : -5001;
    return instance_create_depth(0, 0, _d, obj_titan_attack5);
}

/// all six boxes: the front row (Susie, Ralsei, Queen) in the usual spots, the back row (Pink, Jevil, Spamton) a row
/// above them. the back row doesn't take hits
function scr_party_init_six(_susie_hp, _ralsei_hp, _queen_hp)
{
    scr_party_init_trio(_susie_hp, _ralsei_hp, _queen_hp);
    var _all = [];
    for (var i = 0; i < array_length(global.party); i++) array_push(_all, global.party[i]);
    var _back = function(_name, _hp, _body, _hurt, _idle, _x, _frame, _attack, _col)
    {
        return {
            name: _name, hp: _hp, max_hp: _hp, body: _body, body_hurt_sprite: _hurt, body_idle_sprite: _idle,
            box_offset_x: _x, box_offset_y: -62,   // a row above Queen's (-10): her box's top half (52px) higher
            sprite_frame: _frame, hurt_frame: _frame,
            frame_scale: 52 / 47, divider_y: 47,
            bar_offset_x: 139, bar_offset_y: 30, bar_width: 76, bar_height: 9,
            bar_fill_color: _col,
            hp_current_x: 170, hp_max_x: 185, hp_text_offset_y: 17,
            hurt_flash_time: 20,
            attack_frame: _attack,
            icon_rect_x: 19, icon_rect_y: 16, icon_rect_w: 20, icon_rect_h: 23, hurt_icon_scale: 1
        };
    };
    array_push(_all, _back("Pink",    7000, obj_mewmew,  spr_mewmew_shocked_right_corrupted, spr_mewmew_idle_corrupted, -12, spr_pinkbox_empty,    spr_pinkbox_attack_empty,    make_color_rgb(255, 138, 144)));
    array_push(_all, _back("Jevil",   3500, obj_jevil,   spr_jevil_tired,                    spr_jevil_dance,           224, spr_jevilbox_empty,   spr_jevilbox_attack_empty,   make_color_rgb(109, 109, 192)));
    with ({ e: _all[array_length(_all) - 1] }) { e.bar_offset_x += 1; e.hp_current_x += 1; e.hp_max_x += 1; }   // (his box's art is 1px right of the others')
    array_push(_all, _back("Spamton", 600,  obj_spamton, spr_spamton_hurt,                   spr_spamton_right,         460, spr_spamtonbox_empty, spr_spamtonbox_attack_empty, make_color_rgb(251, 242, 54)));
    scr_party_init(_all);
    with (obj_battle_ui_box) if (char_name == "Pink" || char_name == "Jevil" || char_name == "Spamton") takes_hits = false;
}

global.titan_battle3_song = sng_needsomefriends;   // (already going since the Freedom Gang showed up: it carries on through)

/// everyone's back: the 6-person Titan battle (obj_ralsei_rage starts it once they've readied up).
/// front row (they take the hits): Susie, Ralsei, Queen. back row: Pink, Jevil, Spamton
function scr_titan_battle3_start()
{
    // HP: Ralsei & Queen carry on from their boxes, Susie from before she fell. the Titan carries on too
    var _hp = { Susie: 290, Ralsei: 210, Queen: 1510 };
    with (obj_battle_ui_box) if (variable_struct_exists(_hp, char_name)) _hp[$ char_name] = max(1, hp);
    if (variable_global_exists("post_battle_hp") && variable_struct_exists(global.post_battle_hp, "Susie"))
        _hp.Susie = max(1, global.post_battle_hp.Susie.hp);
    var _thp = 6000;
    with (obj_battle_target) if (kind == "titan") _thp = hp;

    with (obj_UI) instance_destroy();
    instance_create_depth(0, 0, -100, obj_UI);
    scr_party_init_six(_hp.Susie, _hp.Ralsei, _hp.Queen);
    with (obj_battle_ui_box) if (char_name == "Ralsei") { cant_die = true; body_idle_sprite = spr_ralsei_battle_idle_mad; }   // (a hit that'd down him goes to Susie or Queen)
    obj_UI.active_box = noone;

    // the front row centred on the screen, like the 3-person battle (the back row's lined up over it)
    var _cam_cx = camera_get_view_x(view_camera[0]) + camera_get_view_width(view_camera[0]) / 2;
    var _left   = obj_UI.target_x - 1 + obj_UI.boxes_x_correction;
    var _right  = obj_UI.target_x + 460 + obj_UI.boxes_x_correction + sprite_get_width(spr_queenbox_empty) * (52 / 47);
    var _shift  = _cam_cx - (_left + _right) / 2;
    obj_UI.target_x   += _shift;
    obj_UI.onscreen_x += _shift;
    obj_UI.panel_full_width = true;
    obj_UI.follow_cam = true;
    obj_UI.depth = -10002;
    with (obj_battle_ui_box) depth = -10003;

    scr_tp_init();
    global.tp.broken = true;

    // the song: if it's already playing (it is: it started when the Freedom Gang showed up) it just keeps going
    var _playing = variable_global_exists("music") && global.music != noone && audio_is_playing(global.music)
                && variable_global_exists("song") && is_struct(global.song) && global.song.sound == global.titan_battle3_song;
    if (!_playing)
    {
        if (variable_global_exists("music") && global.music != noone) audio_stop_sound(global.music);
        global.song  = { sound: global.titan_battle3_song, beats: 9999 };
        global.music = audio_play_sound(global.titan_battle3_song, 2, true, 1);
        global.song_start = current_time;
    }

    with (obj_battle_target) instance_destroy();
    var _titan = scr_battle_target_make(obj_titan_reveal, {
        kind: "titan", enemy_name: "Titan", side: 1, home_y: 0,
        max_hp: 6000, at: 40, df: 0, rudebuster_mult: 0.5,
        check_text: "* TITAN - AT 40 DF 800\n* The fear of dark, which appears in many forms."
    });
    if (_titan != noone) _titan.hp = max(1, _thp);

    with (obj_battle_menu) instance_destroy();
    with (instance_create_depth(0, 0, -10050, obj_battle_menu, { party_names: ["Susie", "Ralsei", "Queen", "Pink", "Jevil", "Spamton"] }))
    {
        rounds = [
            { talk: [], attack: scr_start_titan_attack6 },
            { talk: [], attack: scr_start_titan_attack7 },
            { talk: [], attack: scr_start_titan_attack8 },
            { talk: [], attack: scr_start_titan_final, no_box: true },   // (the run: no box)
        ];
        rounds_loop_from = 3;
        flavor = [
            "* A new sense of freedom arises.",
            "* Susie cracks her knuckles.",
            "* Spamton is [Thrilled] to be here.",
			"* Pink is ready to throw some claws.",
			"* Jevil keeps dancing.",
			"* Ralsei seems overly determined.",
			"* Queen seems slightly less sustained.",
			"* The darkness looms.",
			"* Life is but a shadow.",
        ];
        first_flavor = "* A new sense of freedom arises.";
        facing_enabled = true;
        default_facing = 1;
        susie_rescue   = false;
        auto_mouth     = true;
        turn_end_hook  = function(_turn) { return scr_titan_battle3_heal(); };
        for (var i = 0; i < party_n; i++) if (names[i] == "Ralsei" && defs[i] != undefined)
        {
            defs[i].idle        = spr_ralsei_battle_idle_mad;
            defs[i].ready_fight = spr_ralsei_attack_ready_serious;
            defs[i].attack      = spr_ralsei_attack_serious;
        }
        for (var i = 0; i < party_n; i++)
        {
            if (defs[i] == undefined) continue;
            scr_bm_idle(defs[i]);
            face_member(i, default_facing);
        }
    }
}

/// the 6-person battle's last attack: the battle ends and obj_titan_finale takes over (the run, then the end)
function scr_start_titan_final()
{
    var _f = instance_create_depth(0, 0, 20, obj_titan_finale);   // (it reads everyone's HP and the Titan's first)
    with (obj_dialogue_chain) instance_destroy();
    with (obj_talkbox) instance_destroy();
    with (obj_soul) instance_destroy();
    with (obj_battlebox) instance_destroy();
    with (obj_battle_target) instance_destroy();
    with (obj_battle_ui_box) instance_destroy();
    with (obj_UI) instance_destroy();
    with (obj_tp_bar) instance_destroy();
    with (obj_queen_shield) instance_destroy();
    with (obj_battle_menu) instance_destroy();
    global.cutscene_lock = true;
    return _f;
}

/// the 6-person battle's remixed attacks (each has the Titan's lasers in it: scr_titan_beams)
function scr_start_titan_attack6()
{
    var _d = instance_exists(obj_battlebox) ? obj_battlebox.depth - 1 : -5001;
    return instance_create_depth(0, 0, _d, obj_titan_attack6);
}
function scr_start_titan_attack7()
{
    var _d = instance_exists(obj_battlebox) ? obj_battlebox.depth - 1 : -5001;
    return instance_create_depth(0, 0, _d, obj_titan_attack7);
}
function scr_start_titan_attack8()
{
    var _d = instance_exists(obj_battlebox) ? obj_battlebox.depth - 1 : -5001;
    return instance_create_depth(0, 0, _d, obj_titan_attack8);
}

/// after the damage numbers (obj_titan_finale runs this): Castle Town, then the Pipis, then the end
function scr_titan_epilogue_start()
{
    with (obj_titan_finale) instance_destroy();
    instance_create_depth(0, 0, -9500, obj_titan_epilogue);
}

/// the 6-person battle: after an enemy turn where anyone got hurt, Ralsei heals everyone back to full
/// (its turn_end_hook: true while it's doing it, then it carries on to the next turn)
function scr_titan_battle3_heal()
{
    var _hurt = false;
    with (obj_battle_ui_box) if (hp < max_hp) _hurt = true;
    if (!_hurt) return false;
    start_script([
        { run: function()
            {
                // Ralsei's spell
                with (obj_ralsei) { sprite_index = spr_ralsei_spell; last_sprite = sprite_index; image_index = 0; image_speed = 1; anim_loop = false; image_xscale = 2; }
                audio_play_sound(snd_spell_pacify, 1, false);
            } },
        { wait: 30 },
        { run: function()
            {
                with (obj_battle_ui_box) if (hp < max_hp)
                {
                    scr_bm_heal(id, max_hp - hp);   // (back up if they were down)
                    if (body != noone && instance_exists(body))
                    {
                        var _f = instance_create_depth(0, 0, body.depth - 1, obj_heal_flash);
                        _f.target   = body;
                        _f.duration = 40;
                    }
                }
            } },
        { say: { spr: -1, img: 0, text: "* Ralsei healed everyone!", voice: noone, auto: 40 } },
    ], function()
    {
        for (var i = 0; i < party_n; i++) if (defs[i] != undefined) { scr_bm_idle(defs[i]); face_member(i, default_facing); }
        turn++; state = "turn_start"; t = 0;
    });
    return true;
}