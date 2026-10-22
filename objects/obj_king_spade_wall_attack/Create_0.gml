// --- tuning ---
// each wall: which side it comes FROM ("left", "right", "top", "bottom"), speed, frames until the next wall,
// and with_next: true launches the next wall on the same frame (crossing walls — its own wait is ignored)
walls = [
    { from: "left",   speed: 2.5, wait: 70 },
    { from: "right",  speed: 2.5, wait: 70 },
    { from: "left",   speed: 3,   wait: 55 },
    { from: "right",  speed: 3,   wait: 55 },
    { from: "top",    speed: 2.5, wait: 70 },
    { from: "bottom", speed: 2.5, wait: 70 },
    { from: "left",   speed: 3,   wait: 0,  with_next: true },
    { from: "top",    speed: 3,   wait: 95 },
    { from: "right",  speed: 3.5, wait: 0,  with_next: true },
    { from: "bottom", speed: 3.5, wait: 95 }
];
spade_spacing   = 28;  // tighter than the hit radius x2, so there's no slipping between spades
gap_size        = 2;   // how many spades are missing from each wall
max_gap_shift   = 3;   // gap moves at most this many slots from the last wall of the same direction
spawn_out       = 20;  // walls start just outside the box
spade_damage    = 36;
spade_hit_radius = 16;
start_delay     = 20;
end_delay       = 70;  // after the last wall launches, before the box closes (walls still crossing)
spawn_sound     = snd_spear_appear; // -1 for none

// warning strip along the edge a wall is about to come from — the gap shows as a hole in it
warn_frames = 45;      // how long the warning shows before the wall launches
warn_depth  = 10;      // how far into the box the strip reaches
warn_inset  = 2;       // space between segments
warn_color  = c_red;
warn_alpha  = 0.7;
warn_sound  = snd_select; // -1 for none
warn_gain   = 0.4;

// --- state ---
depth = obj_battlebox.depth - 1; // warnings draw over the box, under the soul
wall_index = 0;
last_gap_sideways = -1; // walls moving left/right
last_gap_vertical = -1; // walls moving up/down
pending = [];           // walls still in their warning phase
timer = start_delay;
state = "walls";

with (obj_box_bullet_drawer) instance_destroy(); // clear any leftover
instance_create_depth(0, 0, obj_battlebox.depth - 1, obj_box_bullet_drawer);

// decides the wall (direction + gap) and starts its warning
plan_wall = function(_w)
{
    var _in = scr_get_box_interior();
    var _sideways = (_w.from == "left" || _w.from == "right");
    var _span = _sideways ? (_in.y2 - _in.y1) : (_in.x2 - _in.x1);
    var _n = max(gap_size + 1, floor(_span / spade_spacing));

    // pick the gap, never too far from the last one going this way so it's always reachable
    var _last = _sideways ? last_gap_sideways : last_gap_vertical;
    var _max_start = _n - gap_size;
    var _gap = (_last < 0)
        ? irandom(_max_start)
        : clamp(_last + irandom_range(-max_gap_shift, max_gap_shift), 0, _max_start);
    if (_sideways) last_gap_sideways = _gap; else last_gap_vertical = _gap;

    var _dir = 0;
    switch (_w.from)
    {
        case "left":   _dir = 0;   break;
        case "right":  _dir = 180; break;
        case "top":    _dir = 270; break;
        case "bottom": _dir = 90;  break;
    }

    array_push(pending, { from: _w.from, sideways: _sideways, speed: _w.speed, dir: _dir, n: _n, gap: _gap, timer: warn_frames });
    if (warn_sound != -1) audio_play_sound(warn_sound, 5, false, warn_gain);
};

// actually sends the spades in once the warning's done
launch_wall = function(_p)
{
    var _in = scr_get_box_interior();

    for (var k = 0; k < _p.n; k++)
    {
        if (k >= _p.gap && k < _p.gap + gap_size) continue;

        var _t = (k + 0.5) / _p.n;
        var _x, _y;
        if (_p.sideways)
        {
            _x = (_p.from == "left") ? _in.x1 - spawn_out : _in.x2 + spawn_out;
            _y = lerp(_in.y1, _in.y2, _t);
        }
        else
        {
            _x = lerp(_in.x1, _in.x2, _t);
            _y = (_p.from == "top") ? _in.y1 - spawn_out : _in.y2 + spawn_out;
        }

        var _s = instance_create_depth(_x, _y, obj_battlebox.depth - 1, obj_spade_shot);
        _s.move_dir    = _p.dir;
        _s.image_angle = _p.dir;
        _s.move_speed  = _p.speed;
        _s.max_speed   = _p.speed;
        _s.damage      = spade_damage;
        _s.hit_radius  = spade_hit_radius;
    }
};