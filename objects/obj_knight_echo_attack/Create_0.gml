// ===================================================================
// Knight attack 12: "Echo". dark copies of the soul replay exactly
// where it went a moment ago, and touching one hurts, so you can't
// stand still and you can't double back.
//   red        (the Knight)  : echoes follow your path around the box
//   light blue (Susie)       : echoes hop the grid behind you
//   green      (Ralsei)      : every place you've been comes back at you as an echo, block them
// ===================================================================

scr_slashes_init();   // the Knight's cuts + his swing (set first, the swap code reuses the swing)
scr_soul_swap_init(); // the party changing the soul's colour
slash_damage = 45;

// --- tuning ---
start_delay     = 30;    // box open -> the Knight turns it red

echo_damage     = 45;
echo_hit_r      = 9;     // how close an echo has to be to hit
echo_fade_in    = 35;    // an echo can't hurt until it's fully faded in
echo_fade_out   = 20;
echo_trail      = 4;     // faint copies behind each echo
echo_trail_step = 4;     // frames between them
history_cap     = 900;   // frames of movement remembered

// RED: echoes follow your path. at = frame of the phase it joins, delay = how far behind you it is
red_len         = 600;
red_echoes      = [ { at: 0, delay: 90 }, { at: 300, delay: 45 } ];
red_cut_first   = 140;   // the Knight's cuts through the soul, to keep it moving
red_cut_gap     = 120;
red_cut_charge  = 55;

// LIGHT BLUE: echoes hop the grid behind you
blue_len        = 540;
blue_echoes     = [ { at: 0, delay: 60 }, { at: 240, delay: 120 } ];
blue_cut_first  = 110;
blue_cut_gap    = 125;
blue_cut_charge = 60;

// GREEN: places you've been come back as echoes, lined up on the four sides, then thrown at you one at a time
finale_count    = 10;
finale_window   = 480;   // the last this many frames of movement they're picked from
finale_appear   = 20;
finale_slide    = 25;    // frames to slide onto a side
finale_r        = 80;    // distance from the soul they line up at...
finale_stack    = 18;    // ...plus this much for each one already on that side
finale_hold     = 30;    // lined up -> the first one goes
finale_gap_a    = 34;    finale_gap_b   = 18;   // frames between throws, first -> last
finale_speed_a  = 4.5;   finale_speed_b = 6.5;
block_sound     = snd_impact;
spark_frames    = 12;

end_delay       = 50;

// --- state ---
state    = "intro";
timer    = start_delay;
phase_t  = 0;
history  = [];
echoes   = [];
finale   = [];
sparks   = [];
next_cut = 0;
fi       = 0;   // next finale echo to throw

get_soul = function() { return instance_exists(obj_soul) ? instance_find(obj_soul, 0) : noone; }

soul_sprite = function()
{
    var _s = get_soul();
    if (instance_exists(_s)) return _s.base_sprite;
    return spr_soul_red;
}

/// where the soul was _delay frames ago (undefined if it hasn't been that long)
history_at = function(_delay)
{
    var _i = array_length(history) - 1 - _delay;
    if (_i < 0) return undefined;
    return history[_i];
}

/// echoes for this phase join on schedule
add_echoes = function(_list)
{
    for (var i = 0; i < array_length(_list); i++)
    {
        if (_list[i].at == phase_t) array_push(echoes, { delay: _list[i].delay, t: 0, x: 0, y: 0, alpha: 0, dying: false, die_t: 0 });
    }
}

kill_echoes = function()
{
    for (var i = 0; i < array_length(echoes); i++) echoes[i].dying = true;
}

/// red: a single cut through the soul
cut_red = function(_charge)
{
    var _in = scr_get_box_interior();
    var _s  = get_soul();
    var _sx = instance_exists(_s) ? _s.x : (_in.x1 + _in.x2) / 2;
    var _sy = instance_exists(_s) ? _s.y : (_in.y1 + _in.y2) / 2;
    scr_slash_add(scr_slash_clip_line(_sx, _sy, irandom(179), _in), _charge);
}

/// light blue: one grid cut through the soul's sector
cut_blue = function(_charge)
{
    var _all = scr_slash_grid_lines(scr_get_attack_bounds());
    var _s   = get_soul();
    var _sc  = instance_exists(_s) ? _s.grid_c : 1, _sr = instance_exists(_s) ? _s.grid_r : 1;
    var _ok  = [];
    for (var i = 0; i < array_length(_all); i++)
    {
        for (var c = 0; c < 3; c++) if (_all[i].cells[c][0] == _sc && _all[i].cells[c][1] == _sr) { array_push(_ok, _all[i]); break; }
    }
    if (array_length(_ok) == 0) return;
    var _cut = _ok[irandom(array_length(_ok) - 1)];
    scr_slash_add(_cut.seg, _charge, _cut.cells);
}

/// the green finale: picks places from the soul's recent path, gives each a side to come from
build_finale = function()
{
    finale = [];
    var _c   = scr_box_center();
    var _len = array_length(history);
    var _from = max(0, _len - finale_window);
    var _per_side = [0, 0, 0, 0];
    var _last = -1, _same = 0;

    for (var k = 0; k < finale_count; k++)
    {
        var _i = (_len > 0) ? floor(lerp(_from, _len - 1, k / max(finale_count - 1, 1))) : -1;
        var _p = (_i >= 0) ? history[_i] : { x: _c.x + irandom_range(-40, 40), y: _c.y + irandom_range(-30, 30) };

        // the side it's closest to (never the same side three times running)
        var _side = (point_distance(_c.x, _c.y, _p.x, _p.y) < 4) ? irandom(3)
                    : ((round(point_direction(_c.x, _c.y, _p.x, _p.y) / 90) mod 4) + 4) mod 4;
        if (_side == _last && _same >= 2) _side = (_side + choose(1, 3)) mod 4;
        _same = (_side == _last) ? _same + 1 : 1;
        _last = _side;

        var _r = finale_r + finale_stack * _per_side[_side];
        _per_side[_side]++;

        array_push(finale, { sx: _p.x, sy: _p.y, x: _p.x, y: _p.y, side: _side, r: _r, dist: _r,
                             t: 0, state: "appear", alpha: 0, speed: 0 });
    }
    fi = 0;
}

/// a dark copy of the soul with a coloured edge
draw_echo = function(_x, _y, _alpha, _col)
{
    if (_alpha <= 0.01) return;
    var _spr = soul_sprite();
    var _sx = 1, _sy = 1;
    var _s = get_soul();
    if (instance_exists(_s)) { _sx = _s.image_xscale; _sy = _s.image_yscale; }

    gpu_set_fog(true, _col, 0, 1);
    draw_sprite_ext(_spr, 0, round(_x) - 1, round(_y), _sx, _sy, 0, c_white, _alpha);
    draw_sprite_ext(_spr, 0, round(_x) + 1, round(_y), _sx, _sy, 0, c_white, _alpha);
    draw_sprite_ext(_spr, 0, round(_x), round(_y) - 1, _sx, _sy, 0, c_white, _alpha);
    draw_sprite_ext(_spr, 0, round(_x), round(_y) + 1, _sx, _sy, 0, c_white, _alpha);
    gpu_set_fog(true, c_black, 0, 1);
    draw_sprite_ext(_spr, 0, round(_x), round(_y), _sx, _sy, 0, c_white, _alpha);
    gpu_set_fog(false, c_black, 0, 0);
}