// --- tuning ---
start_delay   = 30;   // box open -> the soul starts changing
flip_frames   = 45;   // the soul shaking before it turns red
flip_shake    = 3;    // px at full strength
shake_sound   = snd_charge;
change_sound  = snd_sparklegem;
change_gain   = 1.5;
flash_frames  = 20;
flash_radius  = 40;
red_color     = c_red;
blue_color    = make_color_rgb(66, 252, 255);

// slashes (both phases)
slash_damage     = 45;
hit_color_top    = c_white;
hit_color_bottom = c_white;
cut_sound        = snd_knight_cut;
cut_frames       = 10;   // how long the cut stays on screen
hit_frames       = 4;    // only the first few frames of the cut can hit
cut_width        = 14;   // starting thickness of the cut
hit_half_width   = 6;    // how close to the line counts as a hit
warn_color       = c_red;
warn_blink       = 14;   // last frames of the warning blink

// the Knight swings with every cut (settings in scr_knight_swing_init)
scr_knight_swing_init();

// RED (in the box): the Knight's cuts cross the box through the soul
red_patterns    = ["single", "single", "cross", "parallel", "cross", "fan"];
red_charge_a    = 55; red_charge_b = 40;  // warning time, first -> last
red_gap_a       = 70; red_gap_b    = 50;
parallel_space  = 34;   // px between "parallel" cuts

buster_delay    = 30;   // last red cut clears -> Susie's Rude Buster

// LIGHT BLUE (whole screen): cuts run along the grid's rows, columns and diagonals,
// and every sector they'll pass through lights up first
blue_start_delay = 70;
blue_volleys     = 8;
blue_lines_a     = 1;  blue_lines_b  = 3;   // cuts per volley, first -> last
blue_charge_a    = 75; blue_charge_b = 48;
blue_gap_a       = 60; blue_gap_b    = 35;
blue_followup_at = 4;   // from this volley on, a second quick volley lands right after
followup_charge  = 45;
cell_alpha_max   = 0.4;  // how red a marked sector gets right before the cut
dim_alpha_max    = 0.6;  // background darkens behind the screen grid
grid_fade_frames = 30;
grid_alpha_base  = 0.25;
grid_line_w      = 2;

// back in the box, red again for a short finish
return_delay    = 30;
finale_patterns = ["cross", "fan", "parallel"];
finale_charge   = 40;
finale_gap      = 45;
end_delay       = 40;
glide_lerp      = 0.12;

// --- state ---
state      = "intro";
timer      = start_delay;
vi         = 0;
slashes    = [];
followup   = false;
buster     = noone;
box2       = noone;
shake_x    = 0;
shake_y    = 0;
shake_snd  = -1;
flash_t    = 0;
flash_x    = 0;
flash_y    = 0;
flash_col  = c_white;
grid_fade  = 0;
grid_on    = false;
saved_mode = variable_global_exists("soul_mode") ? global.soul_mode : "red";
last_cut_snd = 0;

knight_swing   = function() { scr_knight_swing(); }
knight_restore = function() { scr_knight_swing_restore(); }

get_soul = function() { return instance_exists(obj_soul) ? instance_find(obj_soul, 0) : noone; }

flash_at = function(_x, _y, _col)
{
    flash_t = flash_frames;
    flash_x = _x;
    flash_y = _y;
    flash_col = _col;
    if (change_sound != noone) audio_play_sound(change_sound, 1, false, change_gain);
    scr_camera_shake(2, 8);
}

/// the part of an endless line (through _px,_py at angle _ang) that's inside the rect. undefined if it misses
clip_line = function(_px, _py, _ang, _r)
{
    var _dx = lengthdir_x(1, _ang), _dy = lengthdir_y(1, _ang);
    var _t0 = -10000, _t1 = 10000;
    var _p = [-_dx, _dx, -_dy, _dy];
    var _q = [_px - _r.x1, _r.x2 - _px, _py - _r.y1, _r.y2 - _py];
    for (var i = 0; i < 4; i++)
    {
        if (abs(_p[i]) < 0.0001) { if (_q[i] < 0) return undefined; continue; }
        var _t = _q[i] / _p[i];
        if (_p[i] < 0) _t0 = max(_t0, _t); else _t1 = min(_t1, _t);
    }
    if (_t0 > _t1) return undefined;
    return { x1: _px + _dx * _t0, y1: _py + _dy * _t0, x2: _px + _dx * _t1, y2: _py + _dy * _t1 };
}

add_slash = function(_seg, _charge, _cells = [])
{
    if (is_undefined(_seg)) return;
    array_push(slashes, { x1: _seg.x1, y1: _seg.y1, x2: _seg.x2, y2: _seg.y2,
                          charge: _charge, t: 0, state: "warn", cells: _cells, swung: false });
}

/// red phase: every pattern goes through the soul, so you always have to move
spawn_red = function(_pattern, _charge)
{
    var _in = scr_get_box_interior();
    var _s  = get_soul();
    var _sx = instance_exists(_s) ? _s.x : (_in.x1 + _in.x2) / 2;
    var _sy = instance_exists(_s) ? _s.y : (_in.y1 + _in.y2) / 2;
    var _a  = irandom(179);

    switch (_pattern)
    {
        case "single":
            add_slash(clip_line(_sx, _sy, _a, _in), _charge);
        break;
        case "cross":
            add_slash(clip_line(_sx, _sy, _a, _in), _charge);
            add_slash(clip_line(_sx, _sy, _a + 90, _in), _charge + 6);
        break;
        case "fan":
            for (var i = 0; i < 3; i++) add_slash(clip_line(_sx, _sy, _a + i * 60, _in), _charge + i * 6);
        break;
        case "parallel":
            for (var i = -1; i <= 1; i++)
            {
                var _ox = lengthdir_x(parallel_space * i, _a + 90), _oy = lengthdir_y(parallel_space * i, _a + 90);
                add_slash(clip_line(_sx + _ox, _sy + _oy, _a, _in), _charge);
            }
        break;
    }
}

/// light blue phase: _n cuts along the screen grid (3 rows, 3 columns, 2 diagonals).
/// the first always covers the soul's sector, and at least one sector is always left safe
spawn_blue = function(_n, _charge)
{
    var _b  = scr_get_attack_bounds();
    var _cw = (_b.x2 - _b.x1) / 3, _ch = (_b.y2 - _b.y1) / 3;

    // every possible cut and the sectors it passes through
    var _all = [];
    for (var i = 0; i < 3; i++)
    {
        var _yy = _b.y1 + (i + 0.5) * _ch, _xx = _b.x1 + (i + 0.5) * _cw;
        array_push(_all, { seg: { x1: _b.x1, y1: _yy, x2: _b.x2, y2: _yy }, cells: [[0, i], [1, i], [2, i]] });
        array_push(_all, { seg: { x1: _xx, y1: _b.y1, x2: _xx, y2: _b.y2 }, cells: [[i, 0], [i, 1], [i, 2]] });
    }
    array_push(_all, { seg: { x1: _b.x1, y1: _b.y1, x2: _b.x2, y2: _b.y2 }, cells: [[0, 0], [1, 1], [2, 2]] });
    array_push(_all, { seg: { x1: _b.x1, y1: _b.y2, x2: _b.x2, y2: _b.y1 }, cells: [[0, 2], [1, 1], [2, 0]] });

    var _s  = get_soul();
    var _sc = instance_exists(_s) ? _s.grid_c : 1, _sr = instance_exists(_s) ? _s.grid_r : 1;

    var _covered = array_create(9, false);
    var _picked  = [];
    var _order   = array_shuffle(array_create_ext(array_length(_all), function(_i) { return _i; }));

    for (var k = 0; k < array_length(_order) && array_length(_picked) < _n; k++)
    {
        var _cut = _all[_order[k]];

        // the first cut has to go through where the soul is
        if (array_length(_picked) == 0)
        {
            var _hits_soul = false;
            for (var c = 0; c < 3; c++) if (_cut.cells[c][0] == _sc && _cut.cells[c][1] == _sr) _hits_soul = true;
            if (!_hits_soul) continue;
        }

        // never cover the whole grid
        var _test = array_create(9, false);
        array_copy(_test, 0, _covered, 0, 9);
        for (var c = 0; c < 3; c++) _test[_cut.cells[c][0] + _cut.cells[c][1] * 3] = true;
        var _safe = 0;
        for (var c = 0; c < 9; c++) if (!_test[c]) _safe++;
        if (_safe < 1) continue;

        _covered = _test;
        array_push(_picked, _cut);
    }

    for (var k = 0; k < array_length(_picked); k++) add_slash(_picked[k].seg, _charge + k * 4, _picked[k].cells);
}