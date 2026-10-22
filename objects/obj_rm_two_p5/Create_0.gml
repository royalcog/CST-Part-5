// rm_two, Part 5: Susie & Ralsei are still at the platform's edge looking up at the Titan's tower.
// Lancer walks up from the bottom of the screen and opens self_1. after that, scr_game_text (self_1 - self_4)
// calls the methods below once its textboxes close; each one unlocks Z again when it's finished.
global.cutscene_lock = true;
global.textbox_top   = true;   // everyone's standing low on the platform, so the textbox goes up top

// --- tuning: where everyone stands (their feet, room px) ---
cx          = room_width / 2;
stand_y     = 394;               // Susie & Ralsei (where Part 4 had them)
susie_x     = cx - 45;
ralsei_x    = cx + 45;
lancer_x    = cx;                // Lancer, between and in front of them
lancer_y    = 456;
queen_x     = cx + 110;          // Queen, off to Lancer's right
queen_y     = 470;
offscreen_y = room_height + 150; // where Lancer and Queen start, below the screen
lancer_walk = 2;                 // px per frame
queen_walk  = 1.5;
intro_wait  = 60;                // frames after the room's fade-in before Lancer shows up
queen_wait  = 20;                // frames after Queen stops before Z works again

// --- tuning: the chair ---
chair_x      = cx + 250;         // its origin (the seat)
chair_y      = 400;
chair_from_y = -150;             // it floats down from above the screen
lancer_board = { x: chair_x - 110, y: lancer_y };   // Lancer walks here, then hops on
lancer_seat  = { dx: -46, dy: 16 };   // his feet, from the chair's origin (its left arm)
queen_seat   = { dx: 4,   dy: 20 };   // her feet, from the chair's origin (the seat)
lancer_hop   = { frames: 24, h: 36 };
queen_hop    = { frames: 32, h: 48 };
board_gap    = 20;               // frames between Lancer landing and Queen hopping on

// --- tuning: the Petal Feather ---
feather_sprite   = spr_petal_feather;
feather_scale    = 2;
susie_turn_sprite = spr_susie_walk_right_neutral;   // she turns to Ralsei first...
susie_hold_sprite = spr_susie_right_hold;           // ...then holds it up
susie_turn_wait  = 20;           // frames between the turn and the hold
feather_fist     = { x: 6.5, y: 1 };   // her raised fist, in spr_susie_right_hold's own pixels
feather_lift     = 14;           // px it rises above her fist
feather_rise     = 24;           // frames
feather_hold     = 75;           // frames it's up before the flash starts
feather_sound    = snd_item;
glow_alpha       = 0.45;         // the pulsing glow behind it
glow_speed       = 0.12;
twinkle_every    = 22;           // frames between little sparkles
white_in         = 30;           // frames to fade fully white
white_hold       = 20;           // frames it holds white before the room changes
tower_room       = rm_tower;

// --- state ---
state   = "setup";
t       = 0;
chair   = noone;
feather = { on: false, t: 0, x: 0, y: 0, alpha: 0 };
twinkles = [];

if (instance_exists(obj_shadow_tint))
{
    // Lancer and Queen get the platform's shadow too
    array_push(obj_shadow_tint.shade_objs, obj_lancer, obj_queen);
}

/// puts _o's feet on (_x, _y)
set_feet = function(_o, _x, _y)
{
    var _f = scr_get_feet(_o);
    _o.x += _x - _f.x;
    _o.y += _y - _f.y;
}

/// _o faces _spr (frame 0, not animating) without its feet moving
face = function(_o, _spr)
{
    if (instance_exists(_o)) scr_set_sprite_keep_feet(_o, _spr);
}

unlock = function() { global.cutscene_lock = false; }

// ---------------------------------------------------------------- Case 1
/// Lancer walks up from the bottom of the screen, then self_1 opens
lancer_enter = function()
{
    var _l = instance_exists(obj_lancer) ? instance_find(obj_lancer, 0) : instance_create_layer(0, 0, "Instances", obj_lancer);
    _l.depth        = -3100;   // in front of Susie & Ralsei
    _l.sprite_index = spr_lancer_up;
    _l.image_speed  = 0;
    set_feet(_l, lancer_x, offscreen_y);
    scr_walk_feet_to(_l, spr_lancer_left, spr_lancer_right, spr_lancer_up, spr_lancer_down, lancer_x, lancer_y, lancer_walk,
        function()
        {
            create_textbox("self_1");
            global.dialogue_self = 1;   // so the next Z opens self_2
        });
}

/// after self_1: Queen walks up from the bottom, and Lancer turns to her
queen_enter = function()
{
    var _q = instance_exists(obj_queen) ? instance_find(obj_queen, 0) : instance_create_layer(0, 0, "Instances", obj_queen);
    _q.depth        = -3200;
    _q.sprite_index = spr_queen_walk_up;
    _q.image_speed  = 0;
    set_feet(_q, queen_x, offscreen_y + 60);
    scr_walk_feet_to(_q, spr_queen_walk_left, spr_queen_walk_right, spr_queen_walk_up, spr_queen_walk_down, queen_x, queen_y, queen_walk,
        function()
        {
            face(obj_lancer, spr_lancer_right);
            scr_call_after_frames(function() { unlock(); }, queen_wait);
        });
}

// ---------------------------------------------------------------- Case 2
/// on Queen's "Chair You Guys Up": the chair floats down next to her, and she turns to it
summon_chair = function()
{
    if (instance_exists(chair)) return;
    chair = instance_create_depth(chair_x, chair_from_y, -3050, obj_queen_chair);   // behind Lancer and Queen, in front of Susie & Ralsei
    chair.summon(chair_y);
    face(obj_queen, spr_queen_walk_right);
}

/// after self_2: Lancer walks over and hops on (its arm), then Queen hops on (the seat)
board_chair = function()
{
    if (!instance_exists(chair)) summon_chair();
    scr_walk_feet_to(obj_lancer, spr_lancer_left, spr_lancer_right, spr_lancer_up, spr_lancer_down, lancer_board.x, lancer_board.y, lancer_walk,
        function()
        {
            chair.add_rider(obj_lancer, lancer_seat.dx, lancer_seat.dy, lancer_hop.frames, lancer_hop.h, spr_lancer_down,
                function()
                {
                    scr_call_after_frames(function()
                    {
                        chair.add_rider(obj_queen, queen_seat.dx, queen_seat.dy, queen_hop.frames, queen_hop.h, spr_queen_walk_down,
                            function() { unlock(); });
                    }, board_gap);
                });
        });
}

// ---------------------------------------------------------------- Case 3
/// after self_3: off it goes. Susie & Ralsei look up to watch
chair_liftoff = function()
{
    face(obj_susie,  spr_susie_walk_up);
    face(obj_ralsei, spr_ralsei_walk_up);
    if (instance_exists(chair)) chair.liftoff(function() { unlock(); });
    else unlock();
}

// ---------------------------------------------------------------- Case 4
/// after self_4: Susie turns to Ralsei, pulls out the Petal Feather, and everything flashes white into the tower
pull_feather = function()
{
    face(obj_susie, susie_turn_sprite);
    state = "feather_turn";
    t = 0;
}

/// fades to white and warps to the tower room (the white fades back off there)
white_warp = function()
{
    with (obj_cutscenefade) instance_destroy();
    var _f = instance_create_depth(0, 0, -9999, obj_cutscenefade);
    _f.fade_color     = c_white;
    _f.fade_target    = 1;
    _f.fade_alpha     = 0;
    _f.fade_step      = 1 / white_in;
    _f.target_room    = tower_room;
    _f.wait_duration  = white_hold;
    _f.old_music_fade_time = 600;
}

/// a little four-point sparkle
draw_twinkle = function(_x, _y, _sz)
{
    var _w = _sz * 0.3;
    draw_primitive_begin(pr_trianglelist);
    draw_vertex(_x, _y - _sz); draw_vertex(_x + _w, _y); draw_vertex(_x, _y + _sz);
    draw_vertex(_x, _y - _sz); draw_vertex(_x - _w, _y); draw_vertex(_x, _y + _sz);
    draw_vertex(_x - _sz, _y); draw_vertex(_x, _y - _w); draw_vertex(_x + _sz, _y);
    draw_vertex(_x - _sz, _y); draw_vertex(_x, _y + _w); draw_vertex(_x + _sz, _y);
    draw_primitive_end();
}