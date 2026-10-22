scr_slashes_init(); // slash + Knight swing settings (override any of them below)

// --- tuning ---
start_delay     = 30;

// cuts that shatter the sectors they pass through
break_volleys   = 7;
break_lines_a   = 1;  break_lines_b  = 2;   // cuts per volley, first -> last
break_charge_a  = 70; break_charge_b = 48;  // warning time
break_gap_a     = 75; break_gap_b    = 50;
min_alive       = 3;  // the sectors you can still reach never drop below this
break_sound     = snd_glassbreak;
break_shake     = 2;

// Susie fixes it
susie_line      = [ { speaker: obj_susie, text: "Can't break us!" } ];
buster_delay    = 25;  // her line starts -> she swings
restore_sound   = snd_sparklegem;
restore_frames  = 30;
finale_delay    = 30;

// then a fast finish on the fixed grid (nothing breaks anymore)
finale_volleys  = 4;
finale_lines_a  = 2;  finale_lines_b = 3;
finale_charge   = 40;
finale_gap      = 38;
end_delay       = 40;

// looks
broken_fill     = make_color_rgb(24, 28, 40);
crack_color     = make_color_rgb(66, 252, 255);
crack_alpha     = 0.55;
break_flash     = 8;    // frames a sector flashes white as it shatters
shard_count     = 7;
shard_gravity   = 0.25;
shard_life      = 45;

// --- state ---
state     = "intro";
timer     = start_delay;
vi        = 0;
shards    = [];
restore_t = 0;
buster    = noone;
chain     = noone;
cells     = array_create(9, undefined);
for (var i = 0; i < 9; i++) cells[i] = { broken: false, t: 0, cracks: [] };

talk = function(_lines)
{
    var _c = instance_create_depth(0, 0, 0, obj_dialogue_chain);
    _c.batches = [ _lines ];
    return _c;
}

get_soul = function() { return instance_exists(obj_soul) ? instance_find(obj_soul, 0) : noone; }

soul_cell = function()
{
    var _s = get_soul();
    return instance_exists(_s) ? (_s.grid_c + _s.grid_r * 3) : 4;
}

/// how many sectors you can walk to from _start, going around broken ones
reachable = function(_blocked, _start)
{
    var _seen = array_create(9, false);
    var _todo = [_start];
    _seen[_start] = true;
    var _n = 0;
    while (array_length(_todo) > 0)
    {
        var _i = array_pop(_todo);
        _n++;
        var _c = _i mod 3, _r = _i div 3;
        var _nb = [];
        if (_c > 0) array_push(_nb, _i - 1);
        if (_c < 2) array_push(_nb, _i + 1);
        if (_r > 0) array_push(_nb, _i - 3);
        if (_r < 2) array_push(_nb, _i + 3);
        for (var k = 0; k < array_length(_nb); k++)
        {
            var _j = _nb[k];
            if (!_seen[_j] && !_blocked[_j]) { _seen[_j] = true; array_push(_todo, _j); }
        }
    }
    return { count: _n, seen: _seen };
}

broken_list = function()
{
    var _b = array_create(9, false);
    for (var i = 0; i < 9; i++) _b[i] = cells[i].broken;
    return _b;
}

/// the soul can't move into broken sectors
push_blocked = function()
{
    var _s = get_soul();
    if (!instance_exists(_s)) return;
    for (var i = 0; i < 9; i++) _s.grid_blocked[i] = cells[i].broken;
}

/// _n cuts along the grid. the first goes through the soul's sector, every cut crosses at least one
/// sector that's still there, and there's always a sector you can still reach that's left safe
spawn_volley = function(_n, _charge, _breaks)
{
    var _all     = scr_slash_grid_lines(scr_get_box_interior());
    var _blocked = broken_list();
    var _sc      = soul_cell();
    var _reach   = reachable(_blocked, _sc).seen;

    // second pass drops the "through the soul" rule, in case nothing fits it
    for (var _pass = 0; _pass < 2; _pass++)
    {
        var _covered = array_create(9, false);
        var _picked  = [];
        var _order   = array_shuffle(array_create_ext(array_length(_all), function(_i) { return _i; }));

        for (var k = 0; k < array_length(_order) && array_length(_picked) < _n; k++)
        {
            var _cut = _all[_order[k]];

            var _live = false, _hits_soul = false;
            for (var c = 0; c < 3; c++)
            {
                var _ci = _cut.cells[c][0] + _cut.cells[c][1] * 3;
                if (!_blocked[_ci]) _live = true;
                if (_ci == _sc) _hits_soul = true;
            }
            if (!_live) continue;
            if (_pass == 0 && array_length(_picked) == 0 && !_hits_soul) continue;

            var _test = array_create(9, false);
            array_copy(_test, 0, _covered, 0, 9);
            for (var c = 0; c < 3; c++) _test[_cut.cells[c][0] + _cut.cells[c][1] * 3] = true;

            var _safe = false;
            for (var c = 0; c < 9; c++) if (_reach[c] && !_test[c]) _safe = true;
            if (!_safe) continue;

            _covered = _test;
            array_push(_picked, _cut);
        }

        if (array_length(_picked) > 0)
        {
            for (var k = 0; k < array_length(_picked); k++)
            {
                var _sl = scr_slash_add(_picked[k].seg, _charge + k * 4, _picked[k].cells);
                _sl.breaks = _breaks;
            }
            return;
        }
    }
}

/// jagged cracks from a point near the middle of the sector out to its edges (0-1 coords)
make_cracks = function()
{
    var _cx = random_range(0.35, 0.65), _cy = random_range(0.35, 0.65);
    var _out = [];
    var _n = irandom_range(4, 5);
    var _a0 = random(360);
    for (var i = 0; i < _n; i++)
    {
        var _a  = _a0 + i * (360 / _n) + random_range(-20, 20);
        var _mx = _cx + lengthdir_x(random_range(0.15, 0.3), _a + random_range(-25, 25));
        var _my = _cy + lengthdir_y(random_range(0.15, 0.3), _a + random_range(-25, 25));
        var _ex = clamp(_cx + lengthdir_x(0.9, _a), 0, 1);
        var _ey = clamp(_cy + lengthdir_y(0.9, _a), 0, 1);
        array_push(_out, [_cx, _cy, _mx, _my, _ex, _ey]);
    }
    return _out;
}

cell_rect = function(_i)
{
    var _b  = scr_get_box_interior();
    var _cw = (_b.x2 - _b.x1) / 3, _ch = (_b.y2 - _b.y1) / 3;
    var _x  = _b.x1 + (_i mod 3) * _cw, _y = _b.y1 + (_i div 3) * _ch;
    return { x1: _x, y1: _y, x2: _x + _cw, y2: _y + _ch };
}

/// a cut landed: shatter what it passed through (not the sector the soul's in, and never so much
/// that you'd be stuck with fewer than min_alive sectors)
on_slash_cut = function(_sl)
{
    if (!variable_struct_exists(_sl, "breaks") || !_sl.breaks) return;

    var _sc   = soul_cell();
    var _test = broken_list();
    var _new  = [];
    for (var c = 0; c < array_length(_sl.cells); c++)
    {
        var _ci = _sl.cells[c][0] + _sl.cells[c][1] * 3;
        if (_ci == _sc || _test[_ci]) continue;
        _test[_ci] = true;
        array_push(_new, _ci);
    }
    if (array_length(_new) == 0 || reachable(_test, _sc).count < min_alive) return;

    for (var k = 0; k < array_length(_new); k++)
    {
        var _ci = _new[k];
        cells[_ci].broken = true;
        cells[_ci].t      = 0;
        cells[_ci].cracks = make_cracks();

        var _r = cell_rect(_ci);
        repeat (shard_count)
        {
            array_push(shards, { x: random_range(_r.x1, _r.x2), y: random_range(_r.y1, _r.y2),
                vx: random_range(-2, 2), vy: random_range(-3, -0.5),
                rot: random(360), vr: random_range(-12, 12), len: random_range(3, 7), life: shard_life });
        }
    }
    if (break_sound != noone) audio_play_sound(break_sound, 1, false, 0.7);
    scr_camera_shake(break_shake, 6);
    push_blocked();
}