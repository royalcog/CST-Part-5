// the Titan Spawn battle at the top of the tower (Susie, Ralsei & Queen, a darkness fight: blue TP bar, less TP gain).
// obj_tower_top_scene calls scr_titanspawn_battle_start() once everyone's in place.

/// the three-box battle UI, same boxes and order as the King fight (Susie, Ralsei, Queen)
function scr_party_init_trio(_susie_hp = 290, _ralsei_hp = 210, _queen_hp = 1510)
{
    scr_party_init([
    {
        name: "Susie", hp: _susie_hp, max_hp: 290, body: obj_susie, body_hurt_sprite: spr_susie_hurt,
        body_down_sprite: spr_susie_fell, body_idle_sprite: spr_susie_battle_idle,
        box_offset_x: -1, box_offset_y: -1,
        sprite_frame: spr_susiebox_empty, hurt_frame: spr_susiebox_hurtempty,
        frame_scale: 43 / 156, divider_y: 156,
        bar_offset_x: 516, bar_offset_y: 88, bar_width: 304, bar_height: 36,
        bar_fill_color: make_color_rgb(255, 0, 255),
        hp_current_x: 642, hp_max_x: 701, hp_text_offset_y: 36,
        hurt_flash_time: 20,
		attack_frame: spr_susiebox_attack_empty,
        icon_rect_x: 51, icon_rect_y: 36, icon_rect_w: 147, icon_rect_h: 102, hurt_icon_scale: 1
    },
    {
        name: "Ralsei", hp: _ralsei_hp, max_hp: 210, body: obj_ralsei, body_hurt_sprite: spr_ralsei_shocked,
        body_down_sprite: spr_ralsei_defeat, body_idle_sprite: spr_ralsei_battle_idle,
        box_offset_x: 236, box_offset_y: 0,
        sprite_frame: spr_ralseibox_empty, hurt_frame: spr_ralseibox_hurtempty,
        frame_scale: 42 / 153, divider_y: 153,
        bar_offset_x: 513, bar_offset_y: 85, bar_width: 304, bar_height: 36,
        bar_fill_color: make_color_rgb(1, 255, 0),
        hp_current_x: 639, hp_max_x: 698, hp_text_offset_y: 33,
        hurt_flash_time: 20,
		attack_frame: spr_ralseibox_attack_empty,
        icon_rect_x: 36, icon_rect_y: 21, icon_rect_w: 137, icon_rect_h: 101, hurt_icon_scale: 0.95
    },
    {
        name: "Queen", hp: _queen_hp, max_hp: 1510, body: obj_queen, body_hurt_sprite: spr_queen_shocked,
        box_offset_x: 460, box_offset_y: -10,
        sprite_frame: spr_queenbox_empty, hurt_frame: spr_queenbox_hurtempty,
        frame_scale: 52 / 47, divider_y: 47,
        bar_offset_x: 139, bar_offset_y: 30, bar_width: 76, bar_height: 9,
        bar_fill_color: make_color_rgb(111, 209, 255),
        hp_current_x: 170, hp_max_x: 185, hp_text_offset_y: 17,
        hurt_flash_time: 20,
		attack_frame: spr_queenbox_attack_empty,
        icon_rect_x: 19, icon_rect_y: 16, icon_rect_w: 20, icon_rect_h: 23, hurt_icon_scale: 1
    }
]);
}

/// sng_chaosspawn, looping (swap it here if the battle gets its own song)
function start_titanspawn_battle_music()
{
    if (variable_global_exists("song") && is_struct(global.song) && global.song.sound == sng_chaosspawn) exit;
    global.song  = { sound: sng_chaosspawn, beats: 9999 };
    global.music = audio_play_sound(global.song.sound, 2, true, 1);
    global.song_start = current_time;
}

/// the battle starts: UI + party boxes in, TP bar in (darkness), music
function scr_titanspawn_battle_start()
{
    with (obj_UI) instance_destroy();
    instance_create_depth(0, 0, -100, obj_UI);
    scr_party_init_trio();
    global.soul_glow_radius = 40;   // Brighten grows it during the battle

    // centre the three boxes on the screen (the King fight's layout sits ~40px right of centre)
    var _cam_cx = camera_get_view_x(view_camera[0]) + camera_get_view_width(view_camera[0]) / 2;
    var _left   = obj_UI.target_x + (-1)  + obj_UI.boxes_x_correction;
    var _right  = obj_UI.target_x + 460   + obj_UI.boxes_x_correction + sprite_get_width(spr_queenbox_empty) * (52 / 47);
    var _shift  = _cam_cx - (_left + _right) / 2;
    obj_UI.target_x   += _shift;
    obj_UI.onscreen_x += _shift;

    // the purple/black panel behind the boxes, stretched across the whole screen (like the Susie/Ralsei layout)
    obj_UI.panel_full_width = true;
    obj_UI.depth = -10002;
    with (obj_battle_ui_box) depth = -10003;   // the boxes draw over it
    scr_tp_reset(true);       // darkness: the bar's blue, DEFEND gives 2%, grazing gives a lot less
    scr_tp_bar_show(true);
    start_titanspawn_battle_music();

    // the menu: the player picks for Susie, Ralsei & Queen each turn
    with (obj_battle_menu) instance_destroy();
    with (instance_create_depth(0, 0, -10050, obj_battle_menu))
    {
        // TODO: the script's rounds go here, one per enemy turn (they loop):
        //   { talk: [ { speaker: obj_susie, text: "..." } ], attack: scr_start_titanspawn_attack1 }
		rounds = [
		    { talk: [], attack: scr_start_titanspawn_attack1 },
		    { talk: [], attack: scr_start_titanspawn_attack2 },
		];
        on_win = undefined;   // what happens once they've won (otherwise Z just opens the next self_ line)
    }
}