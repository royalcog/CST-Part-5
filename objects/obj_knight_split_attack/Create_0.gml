// --- tuning ---
box_scale        = 1;     // box size during this attack (1 = normal)
start_delay      = 20;    // beat after the soul appears before the cutting sword shows up
side_gap         = 10;    // gap between the box and a sword's tip
sword_scale      = 1.5;
tip_angle_offset = 0;     // same as attack 1
fade_in_frames   = 10;
hit_radius       = 6;
damage           = 22;
wave_damage      = 25;  // each wave of light
hit_color_top    = c_white;
hit_color_bottom = c_white;

// the opening cut
cut_charge       = 50;    // white -> red, then it rips through the middle
cut_speed        = 42;
cut_trail_len    = 5;
flight_alpha     = 0.45;
cut_sound        = snd_knight_cut;
seam_flash_fade  = 0.05;

// the halves sliding (always opposite each other)
slide_amp        = 40;    // px each half travels either way
slide_period     = 150;   // frames for one full back-and-forth
slide_ramp       = 40;    // frames to ease the sliding in after the cut
merge_frames     = 40;    // frames to ease back together at the end

// the slashes
slash_count       = 12;
slash_first_delay = 30;
slash_gap         = 60;  slash_gap_end    = 30;   // frames between swords, first -> last
slash_charge      = 45;  slash_charge_end = 26;   // charge time, first -> last
track_stop        = 0.75; // stops aiming at the soul here, then winds up for the swing
track_lerp        = 0.15;
swing_frames      = 8;
swing_arc         = 110;  // degrees the blade sweeps through
slash_sound       = snd_slash;

// the waves of light
wave_speed       = 6;   wave_speed_end = 8;
wave_radius      = 38;  // how curved the crescent is
wave_span        = 42;  // degrees either side of center (crescent width)
wave_thickness   = 5;
wave_trail       = 4;
wave_color       = c_white;

// --- state ---
state        = "intro";
timer        = start_delay;
split_axis   = choose("h", "v"); // h: seam runs left-right, top/bottom halves slide sideways
                                 // v: seam runs up-down, left/right halves slide up/down
slide_dir    = choose(-1, 1);
split_active = false;
slide_t      = 0;
slide_k      = 0;
off_a        = 0;  // top or left half
off_b        = 0;  // bottom or right half
seam_x       = 0;
seam_y       = 0;
seam_flash   = 0;
cut_sword    = undefined;
swords       = [];
waves        = [];
spawned      = 0;
last_side    = -1;
soul_lx      = 0;  // where the soul is in the un-split box
soul_ly      = 0;

if (instance_exists(obj_battlebox))
{
    obj_battlebox.target_scale_x = box_scale;
    obj_battlebox.target_scale_y = box_scale;
}

// --- helpers ---

split_now = function()
{
    split_active = true;
    seam_flash   = 1;
    slide_t      = 0;
    slide_k      = 0;
    if (instance_exists(obj_soul))
    {
        soul_lx = obj_soul.x;
        soul_ly = obj_soul.y;
        obj_soul.split_controlled = true;
    }
    if (instance_exists(obj_battlebox)) obj_battlebox.split_axis = split_axis;
    scr_camera_shake(3, 12);
    state = "slashes";
    timer = slash_first_delay;
}

/// the soul cut along the seam: one piece per half it's touching
soul_parts = function()
{
    var _parts = [];
    if (!instance_exists(obj_soul)) return _parts;

    var _spr = obj_soul.sprite_index;
    var _xs  = obj_soul.image_xscale;
    var _ys  = obj_soul.image_yscale;
    var _sw  = sprite_get_width(_spr);
    var _sh  = sprite_get_height(_spr);
    var _tlx = soul_lx - sprite_get_xoffset(_spr) * _xs;
    var _tly = soul_ly - sprite_get_yoffset(_spr) * _ys;

    if (split_axis == "h")
    {
        var _r = clamp(round((seam_y - _tly) / _ys), 0, _sh);
        if (_r > 0)   array_push(_parts, { px: 0, py: 0,  pw: _sw, ph: _r,       x: _tlx + off_a, y: _tly });
        if (_r < _sh) array_push(_parts, { px: 0, py: _r, pw: _sw, ph: _sh - _r, x: _tlx + off_b, y: _tly + _r * _ys });
    }
    else
    {
        var _c = clamp(round((seam_x - _tlx) / _xs), 0, _sw);
        if (_c > 0)   array_push(_parts, { px: 0,  py: 0, pw: _c,       ph: _sh, x: _tlx,            y: _tly + off_a });
        if (_c < _sw) array_push(_parts, { px: _c, py: 0, pw: _sw - _c, ph: _sh, x: _tlx + _c * _xs, y: _tly + off_b });
    }
    return _parts;
}

/// points that count as "the soul" for hits: its center, or the center of each piece while it's split
soul_targets = function()
{
    var _t = [];
    if (!instance_exists(obj_soul)) return _t;
    if (!split_active)
    {
        array_push(_t, { x: obj_soul.x, y: obj_soul.y });
        return _t;
    }
    var _xs = obj_soul.image_xscale;
    var _ys = obj_soul.image_yscale;
    var _parts = soul_parts();
    for (var i = 0; i < array_length(_parts); i++)
    {
        var _p = _parts[i];
        if (_p.pw * _xs < 3 || _p.ph * _ys < 3) continue; // a sliver poking over the seam doesn't count
        array_push(_t, { x: _p.x + _p.pw * _xs / 2, y: _p.y + _p.ph * _ys / 2 });
    }
    return _t;
}

touches_soul = function(_ax, _ay, _bx, _by, _r)
{
    var _t = soul_targets();
    for (var i = 0; i < array_length(_t); i++)
    {
        if (scr_point_segment_distance(_t[i].x, _t[i].y, _ax, _ay, _bx, _by) <= _r) return true;
    }
    return false;
}

/// crescent shape, bulging toward where it's headed
wave_points = function(_x, _y, _dir)
{
    var _pts = [];
    var _cx = _x - lengthdir_x(wave_radius, _dir);
    var _cy = _y - lengthdir_y(wave_radius, _dir);
    var _n  = 8;
    for (var k = 0; k <= _n; k++)
    {
        var _a = _dir - wave_span + (wave_span * 2) * (k / _n);
        array_push(_pts, { x: _cx + lengthdir_x(wave_radius, _a), y: _cy + lengthdir_y(wave_radius, _a) });
    }
    return _pts;
}

wave_touches_soul = function(_w)
{
    var _pts = wave_points(_w.x, _w.y, _w.dir);
    for (var k = 0; k < array_length(_pts) - 1; k++)
    {
        if (touches_soul(_pts[k].x, _pts[k].y, _pts[k + 1].x, _pts[k + 1].y, hit_radius)) return true;
    }
    return false;
}

draw_wave = function(_x, _y, _dir, _thick, _col, _alpha)
{
    var _pts = wave_points(_x, _y, _dir);
    var _n   = array_length(_pts) - 1;
    draw_set_color(_col);
    draw_set_alpha(_alpha);
    for (var k = 0; k < _n; k++)
    {
        var _mid = (k + 0.5) / _n;
        draw_line_width(_pts[k].x, _pts[k].y, _pts[k + 1].x, _pts[k + 1].y, _thick * (0.3 + 0.7 * sin(pi * _mid)));
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
}

draw_sword_charge = function(_x, _y, _angle, _alpha, _red)
{
    var _a = _angle + tip_angle_offset;
    draw_sprite_ext(spr_roaringknight_sword, 0, _x, _y, sword_scale, sword_scale, _a, c_white, _alpha);
    gpu_set_fog(true, c_red, 0, 1);
    draw_sprite_ext(spr_roaringknight_sword, 0, _x, _y, sword_scale, sword_scale, _a, c_white, _alpha * _red);
    gpu_set_fog(false, c_black, 0, 0);
}

draw_sword_ghost = function(_x, _y, _angle, _alpha)
{
    gpu_set_fog(true, c_red, 0, 1);
    draw_sprite_ext(spr_roaringknight_sword, 0, _x, _y, sword_scale, sword_scale, _angle + tip_angle_offset, c_white, _alpha);
    gpu_set_fog(false, c_black, 0, 0);
}