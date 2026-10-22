// the wide shot after the Titan's hand (changed from the game): the beam comes down on them and Ralsei throws a
// shield up right over their heads that holds it back. the Knight comes down to their level, turns into his flying
// form and zooms through them, smashing into Ralsei and knocking him over, so the shield starts giving way. Ralsei
// yells "Watch out!", and Susie jumps clear as it breaks and the beam hits where they were.
// made by obj_titan_spawn at the cut. everything it draws is in Draw End: in front of everyone, and untinted

scene = instance_exists(obj_rm_two_scene) ? instance_find(obj_rm_two_scene, 0) : noone;
fps_  = game_get_speed(gamespeed_fps);

// --- the beam ---
beam_x     = (instance_exists(obj_dark_fountain) ? obj_dark_fountain.x : room_width / 2) - 6;  // where it crosses the middle of the screen
beam_angle = -12;    // degrees: the top leans right, like the game
beam_scale = 2;
beam_strip = 4;      // px (sprite) per strip when it's wrapping onto the shield: smaller = smoother curve
beam_after = 1.2;    // seconds it keeps firing after the shield breaks...
beam_thin  = 0.15;   // ...then thins out over this long
flash_amt  = 0.75;   // white flash when it hits the shield, and when the shield breaks
flash_time = 0.3;    // seconds to fade

beam_cy = camera_get_view_y(view_camera[0]) + camera_get_view_height(view_camera[0]) / 2;
bdx = lengthdir_x(1, 270 + beam_angle);   // straight down the beam
bdy = lengthdir_y(1, 270 + beam_angle);

// --- Ralsei's shield: a dome right over their heads (seconds after the cut) ---
react_at     = 0.55;   // he sees it coming...
cast_at      = 0.8;    // ...casts...
shield_at    = 1.05;   // ...the shield's up...
slam_at      = 1.25;   // ...and the beam hits it
shield_gap   = 36;     // px from the top of the taller one's head to the top of the dome
shield_r     = 200;    // the dome's radius (smaller = rounder)
shield_arc   = 34;     // half its angle: wide enough to cover both of them
shield_th    = 14;     // thickness
shield_grow  = 0.25;   // seconds to grow in
shield_color = make_color_rgb(1, 255, 0);   // Ralsei's colour, same as the finale's barrier
push_speed   = 6;      // px per second the beam shoves it down onto them...
push_max     = 14;     // ...up to this far
push_jitter  = 1.5;    // px it shudders while it's shoved (double once it's giving way)
crack_every  = 0.45;   // seconds between cracks while he's holding it
spark_rate   = 3;      // sparks per frame where the beam meets it
shard_count  = 36;

// --- the Knight ---
knight_down_at       = 2.8;   // he comes down to their level...
knight_down_time     = 0.8;
knight_level_dy      = -40;   // his middle vs. their feet (negative = up)
knight_transform_gap = 0.4;   // ...a beat, then turns into his flying form, facing them...
knight_fly_gap       = 0.15;  // ...then zooms through them
knight_fly_speed     = 26;    // px per frame
knight_trail_every   = 2;     // frames between afterimages
knight_hit_pad       = 10;    // he hits Ralsei when his middle gets this close to Ralsei's

// --- Ralsei getting smashed over ---
knock_dist         = 220;     // px he's sent flying (clear of the beam)
knock_time         = 0.3;     // seconds
knock_hop          = 14;      // px
ralsei_fall_sprite = spr_ralsei_fall_wince;
ralsei_fall_native = 1;      // which way that sprite faces as drawn (-1 left, 1 right)
ralsei_fall_face   = 1;       // which way he ends up facing (1 = back toward the beam)
hit_sounds         = [snd_impact, snd_hurt];

// --- the shield giving way once he's down ---
give_crack_every = 0.07;      // seconds between cracks...
give_crack_max   = 14;        // ...until it's this cracked, then it just flickers on the brink
give_flicker     = 0.5;       // how much it flickers (0-1)

// --- "Watch out!" and Susie jumping clear ---
watchout_delay    = 0.35;     // after he's hit
watchout_text     = "rm2_ralsei_watchout";
susie_flinch      = spr_susie_shocked;   // as the Knight zips past her (noone to skip)
susie_air         = spr_susie_shocked;
susie_land        = spr_susie_landed;
susie_land_native = -1;       // which way the landed sprite faces as drawn (-1 left, 1 right)
jump_time         = 0.4;      // seconds in the air
jump_h            = 40;       // px
susie_jump        = 160;      // px, away from the beam

// --- Ralsei's cast ---
ralsei_react_sprite = spr_ralsei_shocked;
ralsei_cast_sprite  = spr_ralsei_spell;
ralsei_hold_from    = 3;     // once the cast gets here (arm up, summoning)...
ralsei_hold_to      = 8;     // ...it loops back between these frames while he holds the shield, instead of lowering his arm

// --- sounds (noone to skip) ---
cast_sound      = snd_spell_pacify;
shield_sound    = snd_sparklegem;
blast_sound     = snd_titan_petrify_blast;
blast_offset    = 1.4;                  // played from its hit
hum_sound       = snd_titan_blastloop;  // looping while it pushes on the shield
hum_gain        = 0.7;
hum_delay       = 0.6;                  // seconds after the hit
crack_sound     = snd_impact;
transform_sound = snd_wing;
zoom_sound      = snd_ultraswing;
break_sound     = snd_glassbreak;

// --- state ---
t       = 0;        // frames since the cut
st      = 0;        // frames in the current state
state   = "hold";   // "hold" -> "giving" -> "talk" -> "beam_out" -> "done"
fired   = {};
flash   = 0;
beam_on = false;
beam_ex = 0;        // where the beam ends (the shield, then past the bottom of the screen)
beam_ey = 0;
beam_w  = 1;
beam_t  = 0;
beam_surf = -1;
snd_hum = -1;
crack_t = 0;
give_n  = 0;
shield  = { on: false, grow: 0, cx: 0, cy: 0, push: 0, jx: 0, jy: 0, flash: 0, t: 0, vis: 1, cracks: [] };
shards  = [];
sparks  = [];
kstate  = "";
kt      = 0;
knight_x0     = 0;
knight_from_y = 0;
knight_to_y   = 0;

ralsei  = instance_exists(obj_ralsei) ? obj_ralsei.id : noone;
susie   = instance_exists(obj_susie)  ? obj_susie.id  : noone;
r_phase = "stand"; r_t = 0; r_fx = 0; r_fy = 0;
s_phase = "stand"; s_t = 0; s_fx = 0; s_fy = 0; s_jdir = 1;

play = function(_s, _gain = 1, _offset = 0, _pitch = 1, _loop = false)
{
    return (_s != noone) ? audio_play_sound(_s, 1, _loop, _gain, _offset, _pitch) : -1;
}

/// true the first time it's asked about _key, false after
once = function(_key)
{
    if (variable_struct_exists(fired, _key)) return false;
    fired[$ _key] = true;
    return true;
}

set_feet = function(_o, _x, _y)
{
    var _f = scr_get_feet(_o);
    _o.x += _x - _f.x;
    _o.y += _y - _f.y;
}

party_feet_y = 0;
var _n = 0;
if (instance_exists(ralsei)) { party_feet_y += scr_get_feet(ralsei).y; _n++; }
if (instance_exists(susie))  { party_feet_y += scr_get_feet(susie).y;  _n++; }
party_feet_y = (_n > 0) ? party_feet_y / _n : 394;

/// the beam's x at height _y
line_x = function(_y) { return beam_x + (_y - beam_cy) * bdx / bdy; }

// --- the Knight: placed by his sprite's middle, so the sprites' origins don't matter ---
knight_center = function()
{
    var _k = scene.knight, _s = _k.sprite_index;
    return { x: _k.x + (sprite_get_width(_s) / 2 - sprite_get_xoffset(_s)) * _k.image_xscale,
             y: scene.knight_y0 + (sprite_get_height(_s) / 2 - sprite_get_yoffset(_s)) * _k.image_yscale };
}
knight_place = function(_cx, _cy)
{
    var _k = scene.knight, _s = _k.sprite_index;
    _k.x = _cx - (sprite_get_width(_s) / 2 - sprite_get_xoffset(_s)) * _k.image_xscale;
    scene.knight_y0 = _cy - (sprite_get_height(_s) / 2 - sprite_get_yoffset(_s)) * _k.image_yscale;
}

// --- the shield: an upright slice of a circle, centred over the two of them ---
shield_build = function()
{
    var _top = 100000, _l = 100000, _r = -100000;
    with (obj_susie)  { _top = min(_top, bbox_top); _l = min(_l, bbox_left); _r = max(_r, bbox_right); }
    with (obj_ralsei) { _top = min(_top, bbox_top); _l = min(_l, bbox_left); _r = max(_r, bbox_right); }
    if (_top > 99999) { _top = 300; _l = beam_x - 80; _r = beam_x + 80; }
    shield.cx = (_l + _r) / 2;
    shield.cy = _top - shield_gap + shield_r;
	// aim the beam at the dome's top (it keeps its lean)
    beam_x += shield.cx - line_x(shield.cy - shield_r);
    shield.on = true;
    shield.grow = 0;
    shield.push = 0;
    shield.cracks = [];
}

/// a point on the shield at angle _a (0 = its top), _off px out from its centre line
shield_point = function(_a, _off)
{
    return { x: shield.cx + shield.jx + lengthdir_x(shield_r + _off, 90 + _a),
             y: shield.cy + shield.push + shield.jy + lengthdir_y(shield_r + _off, 90 + _a) };
}

/// where the beam, coming down from (_sx,_sy), first meets the top of the shield
beam_hit_shield = function(_sx, _sy)
{
    var _cx = shield.cx + shield.jx, _cy = shield.cy + shield.push + shield.jy;
    var _R  = shield_r + shield_th / 2;
    var _ox = _sx - _cx, _oy = _sy - _cy;
    var _b  = bdx * _ox + bdy * _oy;
    var _c  = _ox * _ox + _oy * _oy - _R * _R;
    var _disc = _b * _b - _c;
    if (_disc < 0) return undefined;
    var _s = -_b - sqrt(_disc);
    return { x: _sx + bdx * _s, y: _sy + bdy * _s };
}

shield_crack = function()
{
    var _a = random_range(-shield_arc * 0.85, shield_arc * 0.85);
    var _pts = [[_a, -shield_th / 2]];
    for (var k = 1; k <= 3; k++) array_push(_pts, [_a + random_range(-4, 4), -shield_th / 2 + shield_th * k / 3]);
    array_push(shield.cracks, _pts);
    shield.flash = max(shield.flash, 0.6);
    play(crack_sound, 0.6, 0, random_range(0.9, 1.15));
}

shield_shatter = function()
{
    if (!shield.on) return;
    shield.on = false;
    for (var i = 0; i < shard_count; i++)
    {
        var _a  = random_range(-shield_arc, shield_arc);
        var _p  = shield_point(_a, random_range(-shield_th / 2, shield_th / 2));
        var _d  = 270 + beam_angle + _a * 1.5 + random_range(-30, 30);   // blown on and out by the beam
        var _sp = random_range(2, 6);
        array_push(shards, { x: _p.x, y: _p.y, vx: lengthdir_x(_sp, _d), vy: lengthdir_y(_sp, _d),
                             rot: random(360), vr: random_range(-12, 12), len: random_range(5, 12), t: 0 });
    }
}

/// the beam from (_sx,_sy) to (_ex,_ey) along its lean, _ws = how wide (1 = full)
draw_beam = function(_sx, _sy, _ex, _ey, _ws)
{
    var _spr = spr_titanbeam_midsection;
    var _img = floor(beam_t / 2) mod sprite_get_number(_spr);   // 30fps
    var _sw  = sprite_get_width(_spr);
    var _sh  = sprite_get_height(_spr);
    var _xs  = beam_scale * _ws;
    var _len = point_distance(_sx, _sy, _ex, _ey);
    var _nx  = lengthdir_x(1, beam_angle), _ny = lengthdir_y(1, beam_angle);   // across the beam
    for (var _d = 0; _d < _len; _d += _sh * beam_scale)
    {
        var _ph = min(_sh, (_len - _d) / beam_scale);
        var _tx = _sx + bdx * _d - _nx * (_sw / 2) * _xs;   // the piece's top-left corner
        var _ty = _sy + bdy * _d - _ny * (_sw / 2) * _xs;
        draw_sprite_general(_spr, _img, 0, 0, _sw, _ph, _tx, _ty, _xs, beam_scale, beam_angle,
                            c_white, c_white, c_white, c_white, 1);
    }
}