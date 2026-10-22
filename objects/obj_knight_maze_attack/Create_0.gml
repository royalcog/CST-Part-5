// --- box ---
grow_scale_x   = 2;     // box width multiplier
grow_scale_y   = 1.5;   // a true 2x is 600px tall and the screen is 480
recenter_box   = true;  // slides the box to the middle of the screen while it grows so it fits

// --- maze ---
cell_target    = 32;    // rough cell size; the real size stretches so the grid fills the box exactly
wall_thick     = 4;
wall_color     = c_white;
extra_open     = 0.06;  // chance each wall gets knocked out on top of the base maze (a few loops)
soul_half      = 7;     // soul's half-size against the walls (a little under its sprite = forgiving)
start_delay    = 30;    // after the box finishes growing, before the maze appears
wall_fade_in   = 20;
shuffle_every  = 300;   // ~5s between maze changes
shuffle_warn   = 45;    // walls blink this long before they change
shuffle_sound  = snd_impact;
cheat_warn     = 12;    // reaching the goal: the Knight swaps the maze almost instantly
goal_color     = c_yellow;
goal_min_dist  = 0.5;   // goal is at least this fraction of the grid away from the soul
goal_reach_margin = 1.25; // the goal is always at least this many times too far to walk to before the next swap

// --- story beats (frames since the maze appeared) ---
what_at        = 900;   // 15s: "What the..."
cheater_at     = 1800;  // 30s: "You little cheater..."

// --- swords (attack 1's, slower) ---
swords_at          = 900;  // ~halfway to the Rude Buster
sword_total        = 12;   // roughly how many fit before Susie steps in (the ramp below is spread over these)
sword_spawn_gap    = 90;   // frames between swords at first...
sword_spawn_gap_end = 60;  // ...and by the end
sword_charge       = 75;   // longer charge than attack 1 so there's time to get out of line in the maze
sword_charge_end   = 50;
sword_first_delay  = 30;

// --- rude buster ---
buster_sprite      = spr_susie_rudebuster;
buster_fire_frame  = 7;     // the projectile leaves her swing on this frame
buster_projectile  = spr_rudebuster_projectile;
buster_scale       = 2;     // Susie's drawn at 2x, so the blast matches
buster_anim_speed  = 10 / 60; // the projectile's own 10fps color cycle
buster_spawn_x     = 38;    // where it leaves the swing, in her sprite's px from her origin (her scale gets applied)
buster_spawn_y     = -41;
buster_speed       = 14;
buster_trail_len   = 6;
launch_sound       = snd_boost;
break_sounds       = [snd_glassbreak, snd_impact];
break_shake        = 6;
chunks_x           = 6;     // how many pieces the box breaks into
chunks_y           = 5;
debris_gravity     = 0.35;

// --- after the break ---
free_margin    = 8;
arrow_dist     = 30;
arrow_size     = 10;
arrow_blink    = 15;
absorb_sound   = snd_boost;
flash_frames   = 60;

// --- state ---
state       = "grow";
timer       = start_delay;
t           = 0;
cols = 0; rows = 0; cw = 0; ch = 0; ox = 0; oy = 0;
maze        = undefined;
pending     = undefined;
warn_timer  = 0;
next_shuffle = 0;
goal_c      = -1;
goal_r      = -1;
last_path   = "";
wall_alpha  = 0;
said_what   = false;
chain       = noone;
buster      = undefined;
debris      = [];
break_flash = 0;
arrow_timer = 0;
flash_inst  = noone;
swords_started = false;

// ===================== helpers =====================

view_rect = function()
{
    var _cam = view_camera[0];
    var _x = instance_exists(obj_camera_controller) ? obj_camera_controller.cam_x : camera_get_view_x(_cam);
    var _y = instance_exists(obj_camera_controller) ? obj_camera_controller.cam_y : camera_get_view_y(_cam);
    return { x1: _x, y1: _y, x2: _x + camera_get_view_width(_cam), y2: _y + camera_get_view_height(_cam) };
}

talk = function(_lines)
{
    var _c = instance_create_depth(0, 0, 0, obj_dialogue_chain);
    _c.batches = [ _lines ];
    return _c;
}

// wall between (c, r) and (c+1, r)
vrect = function(_c, _r)
{
    var _x = ox + (_c + 1) * cw;
    return { x1: _x - wall_thick / 2, y1: oy + _r * ch - wall_thick / 2,
             x2: _x + wall_thick / 2, y2: oy + (_r + 1) * ch + wall_thick / 2 };
}

// wall between (c, r) and (c, r+1)
hrect = function(_c, _r)
{
    var _y = oy + (_r + 1) * ch;
    return { x1: ox + _c * cw - wall_thick / 2, y1: _y - wall_thick / 2,
             x2: ox + (_c + 1) * cw + wall_thick / 2, y2: _y + wall_thick / 2 };
}

soul_cell = function()
{
    if (!instance_exists(obj_soul)) return [cols div 2, rows div 2];
    return [ clamp(floor((obj_soul.x - ox) / cw), 0, cols - 1),
             clamp(floor((obj_soul.y - oy) / ch), 0, rows - 1) ];
}

/// every cell reachable from every other (random depth-first), plus a few extra gaps
gen_maze = function(_sc, _sr)
{
    var _v = array_create(cols - 1);
    for (var i = 0; i < cols - 1; i++) _v[i] = array_create(rows, true);
    var _h = array_create(cols);
    for (var i = 0; i < cols; i++) _h[i] = array_create(rows - 1, true);

    var _seen  = array_create(cols * rows, false);
    var _stack = [[_sc, _sr]];
    _seen[_sc * rows + _sr] = true;

    while (array_length(_stack) > 0)
    {
        var _top = _stack[array_length(_stack) - 1];
        var _c = _top[0], _r = _top[1];

        var _opts = [];
        if (_c > 0        && !_seen[(_c - 1) * rows + _r]) array_push(_opts, [-1, 0]);
        if (_c < cols - 1 && !_seen[(_c + 1) * rows + _r]) array_push(_opts, [ 1, 0]);
        if (_r > 0        && !_seen[_c * rows + _r - 1])   array_push(_opts, [0, -1]);
        if (_r < rows - 1 && !_seen[_c * rows + _r + 1])   array_push(_opts, [0,  1]);

        if (array_length(_opts) == 0) { array_pop(_stack); continue; }

        var _d  = _opts[irandom(array_length(_opts) - 1)];
        var _nc = _c + _d[0], _nr = _r + _d[1];
        if (_d[0] ==  1) _v[_c][_r]  = false;
        if (_d[0] == -1) _v[_nc][_r] = false;
        if (_d[1] ==  1) _h[_c][_r]  = false;
        if (_d[1] == -1) _h[_c][_nr] = false;

        _seen[_nc * rows + _nr] = true;
        array_push(_stack, [_nc, _nr]);
    }

    for (var i = 0; i < cols - 1; i++) for (var j = 0; j < rows; j++)     if (random(1) < extra_open) _v[i][j] = false;
    for (var i = 0; i < cols; i++)     for (var j = 0; j < rows - 1; j++) if (random(1) < extra_open) _h[i][j] = false;

    return { v: _v, h: _h };
}

/// walking distance (in cells) from (sc, sr) to every cell, plus the route back
bfs = function(_m, _sc, _sr)
{
    var _n    = cols * rows;
    var _dist = array_create(_n, -1);
    var _prev = array_create(_n, -1);
    var _start = _sc * rows + _sr;
    var _q = [_start];
    var _qi = 0;
    _dist[_start] = 0;

    while (_qi < array_length(_q))
    {
        var _id = _q[_qi];
        _qi++;
        var _c = _id div rows, _r = _id mod rows;

        var _nb = [];
        if (_c > 0        && !_m.v[_c - 1][_r]) array_push(_nb, _id - rows);
        if (_c < cols - 1 && !_m.v[_c][_r])     array_push(_nb, _id + rows);
        if (_r > 0        && !_m.h[_c][_r - 1]) array_push(_nb, _id - 1);
        if (_r < rows - 1 && !_m.h[_c][_r])     array_push(_nb, _id + 1);

        for (var k = 0; k < array_length(_nb); k++)
        {
            if (_dist[_nb[k]] == -1)
            {
                _dist[_nb[k]] = _dist[_id] + 1;
                _prev[_nb[k]] = _id;
                array_push(_q, _nb[k]);
            }
        }
    }
    return { dist: _dist, prev: _prev };
}

/// the route to a cell as a string (so two solutions can be compared)
path_string = function(_prev, _goal)
{
    var _path = "";
    var _at = _goal;
    while (_at != -1) { _path = string(_at) + "," + _path; _at = _prev[_at]; }
    return _path;
}

/// a new maze whose goal is too far to walk to before the next swap,
/// never the same spot as last time, and not the same solution as before
build_next = function(_sc, _sr)
{
    var _cell = (cw + ch) / 2;
    var _spd  = instance_exists(obj_soul) ? obj_soul.move_speed : 2;
    var _need = ceil(shuffle_every * _spd * goal_reach_margin / _cell); // steps the soul can't cover in time
    var _last = (goal_c >= 0) ? goal_c * rows + goal_r : -1;
    var _best = undefined;

    repeat (12)
    {
        var _m = gen_maze(_sc, _sr);
        var _b = bfs(_m, _sc, _sr);

        var _far = [];
        var _max = -1, _max_id = -1;
        for (var k = 0; k < cols * rows; k++)
        {
            var _d = _b.dist[k];
            if (_d < 0 || k == _last) continue;
            if (_d > _max) { _max = _d; _max_id = k; }
            if (_d >= _need) array_push(_far, k);
        }

        var _gid  = (array_length(_far) > 0) ? _far[irandom(array_length(_far) - 1)] : _max_id;
        var _cand = { m: _m, gc: _gid div rows, gr: _gid mod rows,
                      path: path_string(_b.prev, _gid), steps: _b.dist[_gid] };

        if (array_length(_far) > 0 && _cand.path != last_path) return _cand;
        if (_best == undefined || _cand.steps > _best.steps) _best = _cand; // fallback: the farthest one found
    }
    return _best;
}

start_swords = function()
{
    swords_started = true;
    var _sw = instance_create_depth(0, 0, depth, obj_knight_sword_attack);

    // attack 1's Create shrinks the box — put ours back before the box notices
    obj_battlebox.target_scale_x = grow_scale_x;
    obj_battlebox.target_scale_y = grow_scale_y;

    with (_sw)
    {
        sword_count       = other.sword_total;
        spawn_gap         = other.sword_spawn_gap;
        spawn_gap_end     = other.sword_spawn_gap_end;
        charge_frames     = other.sword_charge;
        charge_frames_end = other.sword_charge_end;
        timer             = other.sword_first_delay;
    }
}

near_range = function(_x, _y, _half)
{
    return {
        c0: max(floor((_x - _half - ox) / cw) - 1, 0), c1: min(floor((_x + _half - ox) / cw) + 1, cols - 1),
        r0: max(floor((_y - _half - oy) / ch) - 1, 0), r1: min(floor((_y + _half - oy) / ch) + 1, rows - 1)
    };
}

/// knocks out any wall that would land on top of the soul (only adds openings, so nothing gets cut off)
open_around_soul = function(_m)
{
    if (!instance_exists(obj_soul)) return;
    var _hs = soul_half + 1;
    var _l = obj_soul.x - _hs, _t = obj_soul.y - _hs, _rr = obj_soul.x + _hs, _b = obj_soul.y + _hs;
    var _g = near_range(obj_soul.x, obj_soul.y, _hs);
    for (var i = _g.c0; i <= _g.c1; i++)
    for (var j = _g.r0; j <= _g.r1; j++)
    {
        if (i < cols - 1 && _m.v[i][j]) { var _a = vrect(i, j); if (_l < _a.x2 && _rr > _a.x1 && _t < _a.y2 && _b > _a.y1) _m.v[i][j] = false; }
        if (j < rows - 1 && _m.h[i][j]) { var _e = hrect(i, j); if (_l < _e.x2 && _rr > _e.x1 && _t < _e.y2 && _b > _e.y1) _m.h[i][j] = false; }
    }
}

blocked = function(_x, _y)
{
    var _l = _x - soul_half, _t = _y - soul_half, _rr = _x + soul_half, _b = _y + soul_half;
    if (_l < ox || _t < oy || _rr > ox + cols * cw || _b > oy + rows * ch) return true;
    if (maze == undefined) return false;

    var _g = near_range(_x, _y, soul_half);
    for (var i = _g.c0; i <= _g.c1; i++)
    for (var j = _g.r0; j <= _g.r1; j++)
    {
        if (i < cols - 1 && maze.v[i][j]) { var _a = vrect(i, j); if (_l < _a.x2 && _rr > _a.x1 && _t < _a.y2 && _b > _a.y1) return true; }
        if (j < rows - 1 && maze.h[i][j]) { var _e = hrect(i, j); if (_l < _e.x2 && _rr > _e.x1 && _t < _e.y2 && _b > _e.y1) return true; }
    }
    return false;
}

/// moves the soul a pixel at a time per axis, stopping at walls (slides along them)
move_soul = function(_dx, _dy)
{
    var _n = ceil(abs(_dx));
    for (var i = 0; i < _n; i++)
    {
        var _st = sign(_dx) * min(1, abs(_dx) - i);
        if (blocked(obj_soul.x + _st, obj_soul.y)) break;
        obj_soul.x += _st;
    }
    _n = ceil(abs(_dy));
    for (var i = 0; i < _n; i++)
    {
        var _st = sign(_dy) * min(1, abs(_dy) - i);
        if (blocked(obj_soul.x, obj_soul.y + _st)) break;
        obj_soul.y += _st;
    }
}

start_maze = function()
{
    var _in = scr_get_box_interior();
    ox = _in.x1;
    oy = _in.y1;
    var _iw = _in.x2 - _in.x1, _ih = _in.y2 - _in.y1;
    cols = max(3, floor(_iw / cell_target));
    rows = max(3, floor(_ih / cell_target));
    cw = _iw / cols;
    ch = _ih / rows;

    var _sc = cols div 2, _sr = rows div 2;
    if (instance_exists(obj_soul))
    {
        obj_soul.external_move = true;
        obj_soul.x = ox + (_sc + 0.5) * cw;
        obj_soul.y = oy + (_sr + 0.5) * ch;
    }

    var _n = build_next(_sc, _sr);
    maze = _n.m; goal_c = _n.gc; goal_r = _n.gr; last_path = _n.path;
    open_around_soul(maze);

    t = 0;
    next_shuffle = shuffle_every;
    state = "maze";
}

swap_maze = function()
{
    open_around_soul(pending.m);
    maze = pending.m; goal_c = pending.gc; goal_r = pending.gr; last_path = pending.path;
    pending = undefined;
    next_shuffle = t + shuffle_every;
    if (shuffle_sound != noone) audio_play_sound(shuffle_sound, 1, false);
}

start_buster = function()
{
    pending = undefined;
    warn_timer = 0;

    // no new swords once Susie steps in (ones already out finish, or vanish with the box)
    with (obj_knight_sword_attack) spawned = sword_count;

    if (instance_exists(obj_susie))
    {
        with (obj_susie)
        {
            sprite_index = other.buster_sprite;
            last_sprite  = sprite_index; // origins already line up, End Step shouldn't re-anchor her
            image_index  = 0;
            image_speed  = 1;
            anim_loop    = false;
        }
    }
    state = "buster_windup";
}

launch_buster = function()
{
    var _sx = ox, _sy = oy;
    if (instance_exists(obj_susie))
    {
        _sx = obj_susie.x + buster_spawn_x * obj_susie.image_xscale;
        _sy = obj_susie.y + buster_spawn_y * obj_susie.image_yscale;
    }
    var _c = scr_box_center();
    buster = { x: _sx, y: _sy, tx: _c.x, ty: _c.y, dir: point_direction(_sx, _sy, _c.x, _c.y), frame: 0, trail: [] };
    if (launch_sound != noone) audio_play_sound(launch_sound, 1, false);
    state = "buster_fly";
}

break_box = function()
{
    var _c = scr_box_center();

    // the box shatters into chunks
    if (instance_exists(obj_battlebox))
    {
        with (obj_battlebox)
        {
            var _pw = raw_width  / other.chunks_x;
            var _ph = raw_height / other.chunks_y;
            for (var i = 0; i < other.chunks_x; i++)
            for (var j = 0; j < other.chunks_y; j++)
            {
                var _l  = floor(i * _pw), _tt = floor(j * _ph);
                var _w  = floor((i + 1) * _pw) - _l, _h = floor((j + 1) * _ph) - _tt;
                var _wx = x + _l * image_xscale, _wy = y + _tt * image_yscale;
                var _d  = point_direction(_c.x, _c.y, _wx + _w * image_xscale / 2, _wy + _h * image_yscale / 2);
                var _s  = random_range(2, 6);
                array_push(other.debris, { kind: "box", spr: sprite_index, img: image_index,
                    l: _l, t: _tt, w: _w, h: _h, xs: image_xscale, ys: image_yscale,
                    x: _wx, y: _wy, vx: lengthdir_x(_s, _d), vy: lengthdir_y(_s, _d) - random_range(3, 6),
                    rot: 0, vr: random_range(-6, 6) });
            }
        }
        instance_destroy(obj_battlebox);
    }

    // so do the walls
    if (maze != undefined)
    {
        for (var i = 0; i < cols; i++)
        for (var j = 0; j < rows; j++)
        {
            var _list = [];
            if (i < cols - 1 && maze.v[i][j]) array_push(_list, vrect(i, j));
            if (j < rows - 1 && maze.h[i][j]) array_push(_list, hrect(i, j));
            for (var k = 0; k < array_length(_list); k++)
            {
                var _r  = _list[k];
                var _mx = (_r.x1 + _r.x2) / 2, _my = (_r.y1 + _r.y2) / 2;
                var _d  = point_direction(_c.x, _c.y, _mx, _my);
                var _s  = random_range(1.5, 5);
                array_push(debris, { kind: "wall", x: _mx, y: _my, w: _r.x2 - _r.x1, h: _r.y2 - _r.y1,
                    vx: lengthdir_x(_s, _d), vy: lengthdir_y(_s, _d) - random_range(2, 5),
                    rot: 0, vr: random_range(-8, 8) });
            }
        }
    }
    maze = undefined;
    pending = undefined;

    for (var i = 0; i < array_length(break_sounds); i++) audio_play_sound(break_sounds[i], 1, false);
    scr_camera_shake(break_shake, 20);
    break_flash = 1;
    buster = undefined;
    state = "broken";
}

draw_rot_rect = function(_cx, _cy, _w, _h, _ang, _col, _alpha)
{
    var _a = scr_rotate_point(-_w / 2, -_h / 2, _ang);
    var _b = scr_rotate_point( _w / 2, -_h / 2, _ang);
    var _c = scr_rotate_point(-_w / 2,  _h / 2, _ang);
    var _d = scr_rotate_point( _w / 2,  _h / 2, _ang);
    draw_set_color(_col);
    draw_set_alpha(_alpha);
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex(_cx + _a.x, _cy + _a.y);
    draw_vertex(_cx + _b.x, _cy + _b.y);
    draw_vertex(_cx + _c.x, _cy + _c.y);
    draw_vertex(_cx + _d.x, _cy + _d.y);
    draw_primitive_end();
}

draw_wall = function(_now, _next, _r, _blink)
{
    var _a = 0;
    if (_now && _next)       _a = 1;
    else if (_now && !_next) _a = _blink ? 1 : 0.3;     // about to open
    else if (!_now && _next) _a = _blink ? 0.45 : 0.1;  // about to close
    if (_a <= 0) return;
    draw_set_alpha(_a * wall_alpha);
    draw_rectangle(_r.x1, _r.y1, _r.x2 - 1, _r.y2 - 1, false);
}

// ===================== setup =====================

target_base_y = 0;
if (instance_exists(obj_battlebox))
{
    obj_battlebox.target_scale_x = grow_scale_x;
    obj_battlebox.target_scale_y = grow_scale_y;
    var _v = view_rect();
    target_base_y = (_v.y1 + _v.y2) / 2 - obj_battlebox.raw_height / 2;
}