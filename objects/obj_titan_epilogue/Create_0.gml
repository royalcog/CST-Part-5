// after the Titan (scr_titan_epilogue_start makes it, once obj_titan_finale's damage numbers are done).
//   "town": Castle Town. drawn over the tower top (so the tower top stays exactly as it was): Susie & Ralsei on their
//           landed sprites, Pink hurt, Jevil tired. they talk, get up (Jevil doesn't), "Where are..."
//   "top":  back up the tower: Queen & Spamton facing Lancer & King. Lancer moves, King talks, the Pipis rain down into
//           a pile over him, burst into little Spamton heads, which make a wall that shoves him off the edge (it stops
//           right at it). he hangs there a second: "Damn it." black. the fall. the end.
depth = -9500;

// ---------------------------------------------------------------- tuning: Castle Town (screen px, rm_three's view)
town_sprite = spr_castle_town;
town_at     = { x: 431.5, y: -192 };   // where rm_three has it (its origin), from the screen's top-left
music_out   = 2000;     // ms the run's song fades out over
town_wait   = 240;      // frames of black after the Titan's gone, before Castle Town fades in
fade_in     = 60;       // frames for each fade from / to black
black_hold  = 40;
people = [
    { name: "susie",  spr: spr_susie_landed,               up: spr_susie_walk_right_neutral,   x: 290, y: 315, bob: 0 },   // (they face each other)
    { name: "ralsei", spr: spr_ralsei_fall_wince,          up: spr_ralsei_walk_left_neutral,   x: 385, y: 318, bob: 0 },
    { name: "pink",   spr: spr_mewmew_very_hurt_corrupted, up: spr_mewmew_walkright_corrupted, x: 480, y: 312, bob: 0 },   // (her overworld idle)
    { name: "jevil",  spr: spr_jevil_tired,                up: spr_jevil_tired,              x: 580, y: 262, bob: 4 }   // (stays tired, floating)
];
get_up_gap  = 18;       // frames between each one getting up

// ---------------------------------------------------------------- tuning: the tower top (room px)
edge_x      = 244;      // the floor's left edge: the cliff
cam_top_x   = 124;      // the camera, for it
queen_dx    = 230;      // Queen's feet, right of King's...
spamton_dx  = 300;      // ...Spamton's...
spamton_dy  = 6;
lancer_dx   = 110;      // ...Lancer's, between them
lancer_move = { dx: 130, dy: 100 };   // where he moves to (from King's feet)
lancer_walk = 2;
pipis_n     = 160;      // how many come down
pipis_gap   = [10, 1];  // frames between each: at the start / by the end...
pipis_burst = 3;        // ...and over the last quarter, this many at a time
pipis_spread = 70;      // px either side of King's middle they're dropped
pipis_front = 8;        // px in front of his feet the pile starts (so it's in front of him)
pipis_grav  = 0.4;
pipis_scale = 2;
pipis_half  = 11;       // px: half a Pipis' height (at 2x), for stacking
col_w       = 6;        // (the old pile's columns: unused now, but start_rain still sets them up)
floor_spread = 12;      // px up/down from the floor line each one lands (so they scatter over the floor)
pipis_bounce = 0.3;     // how much they bounce when they hit the floor
pile_hold   = 40;       // frames the finished pile sits there before it bursts
// the little Spamton heads they burst into
head_sprite = spr_spamton_head;
head_scale  = 2;
pop_rate    = 3;        // Pipis bursting a frame
head_bounce = 0.4;
wall_cols   = 3;        // the wall of heads: this many columns (the rest fly off)...
wall_gap    = 16;       // ...its left side starting this far right of King (clear of Queen)
form_time   = 50;       // frames the heads take to hop into the wall
form_stagger = 1;       // frames between each one starting to hop
push_acc    = 0.05;     // the wall shoving him left...
push_max    = 3.5;      // (it stops dead at the edge)
king_xs     = -2;       // his kneeling sprite faces left as drawn: -2 faces Queen & Spamton
king_hang_lift = 24;    // px he pops up over the edge (still kneeling)
hang_time   = 70;       // frames he hangs there before "Damn it."
end_hold    = 90;       // frames of black after the impact

// ---------------------------------------------------------------- refs + state
scene = instance_find(obj_tower_top_scene, 0);
vw    = camera_get_view_width(view_camera[0]);
vh    = camera_get_view_height(view_camera[0]);
t     = 0;
phase = "town";
black = { a: 1, to: 1, spd: 0 };   // (it starts black: the end of the run)
for (var i = 0; i < array_length(people); i++) { people[i].up_t = -1; people[i].got_up = false; }
pipis    = [];
raining  = false;
rain_left = 0;
dropped   = 0;
next_drop = 0;
push_v   = 0;
hanging  = false;
pstate   = "";          // the Pipis: "rain" -> "hold" -> "pop" -> "settle" -> "form" -> "ready" -> "push" -> "hang"
stage_t  = 0;
heads    = [];          // { x, y, vx, vy, slot, x0, y0, away }
bursts   = [];          // { x, y, t }
wall_x   = 0;           // the wall's left side
wall_rows = 0;
head_w   = 0;
head_h   = 0;
floor_y  = 0;
king_feet = { x: 0, y: 0 };
cols     = [];
cols_x0  = 0;
arrived  = 0;
fall_snd = -1;

approach = function(_v, _to, _step) { return (_v < _to) ? min(_to, _v + _step) : max(_to, _v - _step); }
spd_of   = function(_spr) { return sprite_get_speed(_spr) / game_get_speed(gamespeed_fps); }
fade_to  = function(_a, _frames) { black.to = _a; black.spd = 1 / max(1, _frames); }
/// _spr's frame _img with the bottom-middle of its canvas on (_x, _y) (whatever its origin is), at 2x
draw_feet = function(_spr, _img, _x, _y)
{
    draw_sprite_ext(_spr, _img, _x + (sprite_get_xoffset(_spr) - sprite_get_width(_spr) / 2) * 2,
                    _y + (sprite_get_yoffset(_spr) - sprite_get_height(_spr)) * 2, 2, 2, 0, c_white, 1);
}

// ---------------------------------------------------------------- the tower top
setup_top = function()
{
    phase = "top";
    with (obj_ralsei_rage) { king_shake.on = false; shield = undefined; }   // (and Queen's shield's gone from him)
    with (obj_queen_shield) instance_destroy();
    with (obj_susie)  visible = false;   // (they're in Castle Town)
    with (obj_ralsei) visible = false;
    with (obj_mewmew) visible = false;
    with (obj_jevil)  visible = false;
    scene.cam_pan.on = false;
    scene.set_cam(cam_top_x);
    var _k = instance_find(obj_king, 0);
    if (_k == noone) return;
    scene.pose_flip(obj_king, spr_king_kneel_sad, king_xs);   // (facing them)
    with (_k) image_speed = 0;
    depth = _k.depth - 20;   // (the Pipis in front of him)
    king_feet = scr_get_feet(_k);
    scene.pose_flip(obj_queen,   spr_queen_walk_left_unhappy, 2);
    scene.pose_flip(obj_spamton, spr_spamton_left, 2);
    scene.pose_flip(obj_lancer,  spr_lancer_right_sad, 2);
    with (obj_queen)   { visible = true; image_speed = 0; }
    with (obj_spamton) { visible = true; image_speed = 0; }
    with (obj_lancer)  { visible = true; image_speed = 0; }
    scene.set_feet(obj_queen,   king_feet.x + queen_dx,   king_feet.y);
    scene.set_feet(obj_spamton, king_feet.x + spamton_dx, king_feet.y + spamton_dy);
    scene.set_feet(obj_lancer,  king_feet.x + lancer_dx,  king_feet.y + 4);
}
lancer_moves = function()
{
    arrived = 0;
    scr_walk_feet_to(obj_lancer, spr_lancer_left_sad, spr_lancer_right_sad, spr_lancer_up, spr_lancer_dt_unhappy,
        king_feet.x + lancer_move.dx, king_feet.y + lancer_move.dy, lancer_walk, function() { arrived = 1; });
}

// --- the Pipis ---
/// the pile's columns: it piles up from the floor just in front of him, so it covers him
start_rain = function()
{
    var _k = instance_find(obj_king, 0);
    cols_x0 = _k.bbox_left - pipis_spread - 120;
    var _n  = ceil((_k.bbox_right + pipis_spread + 120 - cols_x0) / col_w);
    floor_y = king_feet.y + pipis_front;
    cols = array_create(_n, floor_y);
    raining   = true;
    rain_left = pipis_n;
    dropped   = 0;
    next_drop = 20;
    pstate    = "rain";
    stage_t   = 0;
    with (obj_spamton) { image_xscale = -2; sprite_index = spr_spamton_armsout_right; }   // (arms out, facing them)
}
col_of = function(_x) { return clamp(floor((_x - cols_x0) / col_w), 0, array_length(cols) - 1); }
drop_pipis = function()
{
    var _k = instance_find(obj_king, 0);
    var _mid = (_k.bbox_left + _k.bbox_right) / 2;
    array_push(pipis, { x: _mid + random_range(-pipis_spread, pipis_spread), y: camera_get_view_y(view_camera[0]) - 30 - random(40),
                        fy: floor_y - pipis_half + random_range(-floor_spread, floor_spread),   // (where it'll land on the floor)
                        vx: 0, vy: random(2), rot: random(360), vr: random_range(-6, 6), rest: false });
    dropped++;
    if (dropped mod 3 == 0) { var _s = audio_play_sound(snd_bombfall, 1, false, 0.15); audio_sound_pitch(_s, random_range(1.4, 2)); }
}
/// one landing (a little different every time)
land_sound = function()
{
    var _s = audio_play_sound(choose(snd_impact, snd_impact, snd_graze), 1, false, 0.3);
    audio_sound_pitch(_s, random_range(0.8, 1.5));
}
/// the top of the pile at _x (the highest of the columns a Pipis there covers)
surface = function(_x)
{
    var _c = col_of(_x), _top = 99999;
    for (var j = _c - 2; j <= _c + 2; j++) _top = min(_top, cols[clamp(j, 0, array_length(cols) - 1)]);
    return _top;
}
/// is he out of sight under them? (the pile in front of him's up past his head all the way across)
covers_king = function()
{
    var _k = instance_find(obj_king, 0);
    for (var i = 0; i < array_length(cols); i++)
    {
        var _cx = cols_x0 + (i + 0.5) * col_w;
        if (_cx >= _k.bbox_left + 8 && _cx <= _k.bbox_right - 8 && cols[i] > _k.bbox_top + 4) return false;
    }
    return true;
}
/// one Pipis bursts into a little Spamton head
pop_one = function(_sound)
{
    if (array_length(pipis) == 0) return;
    var _i = irandom(array_length(pipis) - 1);
    var _p = pipis[_i];
    array_delete(pipis, _i, 1);
    array_push(heads,  { x: _p.x, y: _p.y, vx: random_range(-2.5, 2.5), vy: random_range(-6, -2), slot: -1, x0: 0, y0: 0, away: false });
    array_push(bursts, { x: _p.x, y: _p.y, t: 0 });
    if (_sound) { var _s = audio_play_sound(snd_bomb, 1, false, 0.3); audio_sound_pitch(_s, random_range(1.3, 1.9)); }
}
/// every head gets a spot in the wall (to his right), the ones left over fly off
form_wall = function()
{
    var _k = instance_find(obj_king, 0);
    head_w    = sprite_get_width(head_sprite)  * head_scale;
    head_h    = sprite_get_height(head_sprite) * head_scale;
    wall_rows = ceil((floor_y - _k.bbox_top) / head_h) + 1;
    wall_x    = _k.bbox_right + wall_gap;
    for (var i = 0; i < array_length(heads); i++)
    {
        var _h = heads[i];
        _h.x0 = _h.x; _h.y0 = _h.y;
        if (i < wall_cols * wall_rows) _h.slot = i;
        else { _h.away = true; _h.vx = random_range(-3, 3); _h.vy = random_range(-9, -6); }
    }
}
slot_x = function(_slot) { return wall_x + (_slot div wall_rows) * head_w + head_w / 2; }
slot_y = function(_slot) { return floor_y - (_slot mod wall_rows) * head_h - head_h / 2; }

// ---------------------------------------------------------------- the steps
steps   = [];
step_i  = 0;
step_t  = 0;
step_on = false;
add = function(_run, _until = undefined, _wait = 0)
{
    var _st = {};
    _st[$ "run"]   = _run;
    _st[$ "until"] = _until;
    _st[$ "wait"]  = _wait;
    array_push(steps, _st);
}

// ---- Castle Town
add(function()
{
    if (variable_global_exists("music")) audio_sound_gain(global.music, 0, music_out);
}, undefined, town_wait);
add(function() { fade_to(0, fade_in); }, function() { return black.a <= 0; }, 50);
add(function() { create_textbox("self_25"); }, function() { return !instance_exists(obj_textbox); }, 20);
add(function()
{
    // everyone gets up (Jevil's still tired)
    for (var i = 0; i < array_length(people); i++) people[i].up_t = t + i * get_up_gap;
    if (variable_global_exists("music")) audio_stop_sound(global.music);
}, undefined, get_up_gap * 3 + 30);
add(function()
{
    for (var i = 0; i < array_length(people); i++) if (people[i].name == "ralsei") people[i].up = spr_ralsei_walk_right_neutral;   // (he turns: "Wait...")
    create_textbox("self_26");
}, function() { return !instance_exists(obj_textbox); }, 20);
add(function() { fade_to(1, fade_in); }, function() { return black.a >= 1; }, black_hold);

// ---- back up the tower
add(function() { setup_top(); fade_to(0, fade_in); }, function() { return black.a <= 0; }, 30);
add(function() { create_textbox("self_27"); }, function() { return !instance_exists(obj_textbox); }, 10);
add(function() { lancer_moves(); }, function() { return arrived == 1; }, 10);
add(function()
{
    scene.pose_flip(obj_lancer, spr_lancer_left_sad, 2);   // (still sad, watching his dad)
    with (obj_lancer) image_speed = 0;
}, undefined, 20);
add(function() { create_textbox("self_28"); }, function() { return !instance_exists(obj_textbox); }, 20);
add(function() { start_rain(); }, function() { return pstate == "ready"; }, 20);   // (rain, pile, burst, wall)
add(function()
{
    pstate  = "push";
    stage_t = 0;
    audio_play_sound(snd_screenshake, 1, false);
}, function() { return hanging; }, hang_time);
add(function() { create_textbox("self_29"); }, function() { return !instance_exists(obj_textbox); });
add(function()
{
    // straight to black, and just the sound of it
    black.a = 1; black.to = 1;
    fall_snd = audio_play_sound(snd_closet_fall, 1, false);
}, function() { return !audio_is_playing(fall_snd); });
add(function() { fall_snd = audio_play_sound(snd_closet_impact, 1, false); }, function() { return !audio_is_playing(fall_snd); }, end_hold);
add(function()
{
    global.part5_over = true;
    var _next = asset_get_index("scr_part5_end");
    if (_next != -1) script_execute(_next);
});