// ===================================================================
// Knight attack 11: "Prism". the soul keeps changing colour on the
// Knight's command: red -> light blue -> green, then mixed together,
// with the next colour's threats already flying while it changes.
// ===================================================================

// --- tuning ---
start_delay   = 30;    // box open -> first change
swap_warn     = 30;    // ring of the next colour closing in before the change lands
swap_ring_r   = 34;    // how big the ring starts
change_sound  = snd_sparklegem;
change_gain   = 1.5;
flash_frames  = 20;
flash_radius  = 40;
green_glide   = 10;    // frames the soul takes to slide to the middle when it turns green

// who changes it: green = Ralsei's spell, light blue = Susie's Rude Buster (lands on the soul, box stays),
// red = the Knight swings at the soul (times the swing so it lands right as the ring closes)
ralsei_cast_sprite = spr_ralsei_spell;
ralsei_idle_sprite = spr_ralsei_battle_idle;
ralsei_cast_frame  = 4;    // frame of his spell where the magic goes off
ralsei_cast_sound  = snd_spell_pacify;
ralsei_est         = 30;   // about how long his cast takes (also the fallback if he's down)
susie_est          = 60;   // about how long the buster takes to wind up + land (also the fallback if she's down)
swap_cap           = 150;  // never wait longer than this for a cast
knight_mark_sound  = snd_slash;
knight_mark_frames = 14;   // the red slash across the soul when the Knight's swing lands
knight_mark_len    = 44;

col_red       = c_red;
col_blue      = make_color_rgb(66, 252, 255);
col_green     = make_color_rgb(0, 255, 64);

// swords (fly in from a side along a lane, blocked by the shield if green, dodged otherwise)
sword_scale   = 1.2;
sword_damage  = 45;
sword_hit_r   = 7;     // how close the blade has to pass to hit a red/light blue soul
spawn_dist    = 300;   // how far out they start
fade_in       = 10;
fade_out_px   = 40;    // fades out over this much once it's past the far side of the box
block_sound   = snd_impact;
spark_frames  = 12;
tip_off       = (sprite_get_bbox_right(spr_roaringknight_sword) + 1 - sprite_get_xoffset(spr_roaringknight_sword)) * sword_scale; // origin -> tip
blade_len     = (sprite_get_bbox_right(spr_roaringknight_sword) - sprite_get_bbox_left(spr_roaringknight_sword) + 1) * sword_scale;

// cuts (shared Knight slash code)
scr_slashes_init();
slash_damage   = 45;
parallel_space = 34;

end_delay = 50;

// --- state ---
state      = "intro";
timer      = start_delay;
beats      = [];
bi         = 0;
swords     = [];
sparks     = [];
swapping   = false;
swap_el    = 0;     // frames since the change started
swap_est   = 1;     // about how long it'll take (for the ring)
buster     = noone;
ralsei_cast = false;
knight_swing_at = 0;     // frame of the change where the Knight starts swinging
knight_swung    = false;
mark_t     = 0;
mark_x     = 0;
mark_y     = 0;
mark_ang   = 0;
next_mode  = "red";
glide_t    = 0;
flash_t    = 0;
flash_x    = 0;
flash_y    = 0;
flash_col  = c_white;
last_side  = -1;
same_count = 0;
spin_side  = irandom(3);
spin_step  = choose(1, -1);
saved_mode = variable_global_exists("soul_mode") ? global.soul_mode : "red";

get_soul = function() { return instance_exists(obj_soul) ? instance_find(obj_soul, 0) : noone; }

mode_color = function(_m)
{
    if (_m == "lightblue") return col_blue;
    if (_m == "green")     return col_green;
    return col_red;
}

// ------------------------------------------------------------ colour changes

party_up = function(_obj) { return instance_exists(_obj) && scr_party_is_up(_obj); }

start_swap = function(_mode)
{
    var _s = get_soul();
    if (!instance_exists(_s)) return;
    if (_s.soul_mode == _mode && !swapping) return; // already that colour

    next_mode = _mode;
    swapping  = true;
    swap_el   = 0;
    swap_est  = swap_warn;
    buster    = noone;

    if (_mode == "red")
    {
        // the ring always gets at least swap_warn; the swing starts late enough to land right as it closes
        swap_est        = max(swap_warn, knight_swing_lead);
        knight_swing_at = swap_est - knight_swing_lead;
        knight_swung    = false;
    }
    else if (_mode == "green")
    {
        swap_est = ralsei_est;
        ralsei_cast = party_up(obj_ralsei);
        if (ralsei_cast)
        {
            scr_set_battle_sprite(obj_ralsei, ralsei_cast_sprite, noone, false);
            if (ralsei_cast_sound != noone) audio_play_sound(ralsei_cast_sound, 1, false);
        }
    }
    else if (_mode == "lightblue")
    {
        swap_est = susie_est;
        if (party_up(obj_susie))
        {
            buster = instance_create_depth(0, 0, depth - 1, obj_rude_buster);
            buster.break_on_hit = false; // it hits the soul, the box stays
            buster.target_x = _s.x;
            buster.target_y = _s.y;
        }
    }
}

/// has whoever's changing it actually landed it yet?
swap_ready = function()
{
    if (swap_el >= swap_cap) return true;
    switch (next_mode)
    {
        case "green":
            if (!ralsei_cast) return swap_el >= ralsei_est;
            if (!instance_exists(obj_ralsei) || obj_ralsei.sprite_index != ralsei_cast_sprite) return true; // got interrupted (hurt etc)
            return floor(obj_ralsei.image_index) >= ralsei_cast_frame;

        case "lightblue":
            if (buster == noone) return swap_el >= susie_est;
            if (!instance_exists(buster)) return true;
            return buster.landed;

        default: // red: on the Knight's hit frame
            return swap_el >= swap_est;
    }
}

do_swap = function()
{
    swapping = false;
    var _s = get_soul();
    if (!instance_exists(_s)) return;

    global.soul_mode = next_mode;
    scr_soul_set_mode(_s, next_mode); // light blue also puts it back on the middle sector

    if (next_mode == "green")
    {
        _s.shield_on  = true;
        _s.shield_pop = 0;
        _s.external_move = true; // slides to the middle first, then the shield takes over
        glide_t = green_glide;
    }
    else
    {
        _s.shield_on = false;
        _s.external_move = false;
        glide_t = 0;
    }
    if (next_mode == "red")
    {
        // his swing lands: a red slash right across the soul
        mark_t   = knight_mark_frames;
        mark_x   = _s.x;
        mark_y   = _s.y;
        mark_ang = choose(30, 150) + irandom_range(-15, 15);
        if (knight_mark_sound != noone) audio_play_sound(knight_mark_sound, 1, false);
    }
    flash_t   = flash_frames;
    flash_x   = _s.x;
    flash_y   = _s.y;
    flash_col = mode_color(next_mode);
    if (change_sound != noone) audio_play_sound(change_sound, 1, false, change_gain);
    scr_camera_shake(2, 8);
}

// ------------------------------------------------------------ swords

pick_side = function(_how)
{
    if (is_real(_how)) { last_side = _how; return _how; }
    if (_how == "spin")
    {
        var _sp = spin_side;
        spin_side = (spin_side + spin_step + 4) mod 4;
        last_side = _sp;
        return _sp;
    }
    if (_how == "opposite") { last_side = (last_side + 2) mod 4; return last_side; }
    if (_how == "same")     return max(last_side, 0);

    var _sd = irandom(3);
    if (_sd == last_side && same_count >= 2) _sd = (_sd + 1 + irandom(2)) mod 4;
    same_count = (_sd == last_side) ? same_count + 1 : 1;
    last_side  = _sd;
    return _sd;
}

/// sideways offset from the box's middle line. _lane: "center", "soul", "random", or -1 / 0 / 1 (a grid row/column)
pick_lane = function(_side, _lane)
{
    var _b = scr_get_attack_bounds();
    var _c = scr_box_center();
    var _horiz = (_side == 0 || _side == 2);
    var _cell  = _horiz ? (_b.y2 - _b.y1) / 3 : (_b.x2 - _b.x1) / 3;
    var _s = get_soul();

    if (is_real(_lane)) return _lane * _cell;
    if (_lane == "random") return irandom_range(-1, 1) * _cell;
    if (_lane == "soul" && instance_exists(_s))
    {
        if (_s.soul_mode == "green") return 0;
        if (_s.soul_mode == "lightblue") return (_horiz ? _s.grid_r : _s.grid_c) * _cell - _cell;
        var _off = _horiz ? _s.y - _c.y : _s.x - _c.x;
        return clamp(_off, -_cell * 1.4, _cell * 1.4);
    }
    return 0;
}

spawn_sword = function(_side_how, _lane, _speed)
{
    var _side = pick_side(_side_how);
    array_push(swords, { side: _side, ang: _side * 90, lane: pick_lane(_side, _lane),
                         dist: spawn_dist, speed: _speed, t: 0, alpha: 0 });
}

/// where a sword's tip is
sword_tip = function(_w, _c)
{
    var _x = _c.x + lengthdir_x(_w.dist, _w.ang);
    var _y = _c.y + lengthdir_y(_w.dist, _w.ang);
    if (_w.side == 0 || _w.side == 2) _y += _w.lane; else _x += _w.lane;
    return { x: _x, y: _y };
}

// ------------------------------------------------------------ cuts

/// red: every pattern goes through the soul
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
            scr_slash_add(scr_slash_clip_line(_sx, _sy, _a, _in), _charge);
        break;
        case "cross":
            scr_slash_add(scr_slash_clip_line(_sx, _sy, _a, _in), _charge);
            scr_slash_add(scr_slash_clip_line(_sx, _sy, _a + 90, _in), _charge + 6);
        break;
        case "fan":
            for (var i = 0; i < 3; i++) scr_slash_add(scr_slash_clip_line(_sx, _sy, _a + i * 60, _in), _charge + i * 6);
        break;
        case "parallel":
            for (var i = -1; i <= 1; i++)
            {
                var _ox = lengthdir_x(parallel_space * i, _a + 90), _oy = lengthdir_y(parallel_space * i, _a + 90);
                scr_slash_add(scr_slash_clip_line(_sx + _ox, _sy + _oy, _a, _in), _charge);
            }
        break;
    }
}

/// light blue: _n cuts along the grid's rows/columns/diagonals. the first covers the soul's sector, one sector always stays safe
spawn_blue = function(_n, _charge)
{
    var _all = scr_slash_grid_lines(scr_get_attack_bounds());
    var _s   = get_soul();
    var _sc  = instance_exists(_s) ? _s.grid_c : 1, _sr = instance_exists(_s) ? _s.grid_r : 1;

    var _covered = array_create(9, false);
    var _picked  = [];
    var _order   = array_shuffle(array_create_ext(array_length(_all), function(_i) { return _i; }));

    for (var k = 0; k < array_length(_order) && array_length(_picked) < _n; k++)
    {
        var _cut = _all[_order[k]];
        if (array_length(_picked) == 0)
        {
            var _hits = false;
            for (var c = 0; c < 3; c++) if (_cut.cells[c][0] == _sc && _cut.cells[c][1] == _sr) _hits = true;
            if (!_hits) continue;
        }
        var _test = array_create(9, false);
        array_copy(_test, 0, _covered, 0, 9);
        for (var c = 0; c < 3; c++) _test[_cut.cells[c][0] + _cut.cells[c][1] * 3] = true;
        var _safe = 0;
        for (var c = 0; c < 9; c++) if (!_test[c]) _safe++;
        if (_safe < 1) continue;
        _covered = _test;
        array_push(_picked, _cut);
    }
    for (var k = 0; k < array_length(_picked); k++) scr_slash_add(_picked[k].seg, _charge + k * 4, _picked[k].cells);
}

// ------------------------------------------------------------ the script
// each beat runs, then waits `wait` frames before the next one.
// a "mode" beat only STARTS the change (it lands swap_warn frames later),
// so anything after it with a short wait is already coming while the colour changes.

add_beat = function(_beat) { array_push(beats, _beat); }

b_mode   = function(_m, _wait)                { add_beat({ act: "mode", m: _m, wait: _wait }); }
b_red    = function(_pattern, _charge, _wait) { add_beat({ act: "red", p: _pattern, charge: _charge, wait: _wait }); }
b_blue   = function(_n, _charge, _wait)       { add_beat({ act: "blue", n: _n, charge: _charge, wait: _wait }); }
b_sword  = function(_side, _lane, _spd, _wait){ add_beat({ act: "sword", side: _side, lane: _lane, spd: _spd, wait: _wait }); }
b_swords = function(_count, _side, _lane, _spd, _gap) { repeat (_count) b_sword(_side, _lane, _spd, _gap); }
b_clear  = function(_wait)                    { add_beat({ act: "clear", wait: _wait }); } // waits for everything on screen to finish
b_await  = function(_wait)                    { add_beat({ act: "await", wait: _wait }); } // waits for the colour change to land

// ---- 1. RED: cuts through the soul, swords down its row/column
b_mode("red", 0);
b_await(20);
b_red("single", 55, 60);
b_sword("random", "soul", 5, 40);
b_red("cross", 50, 60);
b_sword("random", "soul", 5, 15);
b_sword("opposite", "soul", 5, 50);
b_red("parallel", 48, 60);
b_red("fan", 45, 40);
b_clear(25);

// ---- 2. LIGHT BLUE (Susie): grid cuts, swords down the rows/columns
b_mode("lightblue", 0);
b_await(25);
b_blue(1, 70, 70);
b_sword("random", "soul", 5, 35);
b_blue(2, 65, 70);
b_swords(3, "random", "random", 5, 22);
b_blue(2, 58, 30);
b_sword("random", "soul", 5.5, 40);
b_clear(25);

// ---- 3. GREEN (Ralsei): block
b_mode("green", 0);
b_await(25);
b_swords(6, "random", "center", 5, 30);
b_swords(6, "spin", "center", 5.5, 20);
b_clear(30);

// ---- 4. MIXED
// a) green -> red: three swords are already headed for the middle when the shield wears off. get out of the line
b_mode("red", 0);
b_sword("random", "center", 3.5, 12);
b_sword("random", "center", 3.5, 12);
b_sword("random", "center", 3.5, 60);
b_red("single", 50, 60);
b_clear(15);

// b) red -> light blue: the grid cuts get marked the moment Susie swings, while it's still red
b_mode("lightblue", 0);
b_blue(2, 100, 0);
b_await(45);
b_sword("random", "soul", 5, 40);
b_clear(15);

// c) light blue -> green: a wall of three swords from one side as Ralsei casts.
// the outer two miss once you're in the middle, block the middle one
b_sword("random", -1, 4, 0);
b_sword("same", 0, 4, 0);
b_sword("same", 1, 4, 0);
b_mode("green", 0);
b_await(35);
b_swords(2, "random", "center", 5, 28);
b_clear(20);

// d) they start trading it back and forth fast
repeat (2)
{
    b_mode("red", 0);       b_await(10); b_red("cross", 45, 55);
    b_mode("lightblue", 0); b_await(10); b_blue(2, 50, 55);
    b_mode("green", 0);     b_await(10); b_swords(3, "spin", "center", 6, 18);
    b_clear(10);
}

// e) finish: red, with swords down BOTH middle lines at once. any corner is safe
b_mode("red", 0);
b_await(5);
b_sword(0, "center", 3.5, 0);
b_sword(1, "center", 3.5, 0);
b_sword(2, "center", 3.5, 0);
b_sword(3, "center", 3.5, 20);
b_red("fan", 50, 20);
b_clear(0);