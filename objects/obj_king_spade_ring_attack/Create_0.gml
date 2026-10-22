// --- tuning ---
// each wave: spade count, ring radius, wind-up frames, stagger (frames between each spade firing; 0 = all at once),
// and double: true adds a second, wider ring offset between the first ring's spades, firing just after
waves = [
    { count: 6,  radius: 80, aim: 50, stagger: 0 },
    { count: 7,  radius: 80, aim: 45, stagger: 0 },
    { count: 8,  radius: 90, aim: 40, stagger: 6 },
    { count: 6,  radius: 70, aim: 40, stagger: 0, double: true },
    { count: 10, radius: 95, aim: 40, stagger: 4 },
    { count: 8,  radius: 75, aim: 35, stagger: 0, double: true }
];
double_gap     = 30;   // outer ring sits this much farther out...
double_delay   = 14;   // ...and fires this many frames after the inner one
ring_margin    = 10;   // ring is shifted so every spade spawns inside the box (visible during the wind-up)
fire_speed     = 1;    // spades start slow...
fire_accel     = 0.25; // ...and speed up
fire_max_speed = 7;
lock_frames    = 10;   // stop tracking the soul this many frames before firing
spade_damage     = 36;
spade_hit_radius = 12;
start_delay    = 20;
wave_pause     = 90;   // after a wave's last spade fires, before the next wave appears
end_delay      = 30;   // after the last wave fires, before the box closes (spades still flying)
spawn_sound    = snd_spear_appear; // -1 for none
fire_sound     = snd_smallswing;   // -1 for none

// --- state ---
wave_index  = 0;
wave_spades = [];
timer = start_delay;
state = "start";

with (obj_box_bullet_drawer) instance_destroy(); // clear any leftover
instance_create_depth(0, 0, obj_battlebox.depth - 1, obj_box_bullet_drawer);

spawn_ring = function(_cx, _cy, _count, _radius, _aim, _stagger, _angle_offset)
{
    for (var i = 0; i < _count; i++)
    {
        var _a = _angle_offset + i * 360 / _count;
        var _s = instance_create_depth(_cx + lengthdir_x(_radius, _a), _cy + lengthdir_y(_radius, _a),
            obj_battlebox.depth - 1, obj_spade_shot);

        _s.image_angle = _a + 180 + random_range(-90, 90); // swings into its aim during the wind-up
        _s.move_dir    = _a + 180;
        _s.aim_frames  = _aim + i * _stagger;
        _s.lock_frames = lock_frames;
        _s.move_speed  = fire_speed;
        _s.accel       = fire_accel;
        _s.max_speed   = fire_max_speed;
        _s.damage      = spade_damage;
        _s.hit_radius  = spade_hit_radius;
        _s.fire_sound  = fire_sound;
        _s.entered     = true; // spawns inside the box

        array_push(wave_spades, _s);
    }
};

spawn_wave = function(_w)
{
    wave_spades = [];

    var _double = variable_struct_exists(_w, "double") && _w.double;
    var _r_max  = _w.radius + (_double ? double_gap : 0);

    // centered on the soul, but pushed inward so the whole ring fits in the box
    var _in = scr_get_box_interior();
    var _cx = instance_exists(obj_soul) ? obj_soul.x : (_in.x1 + _in.x2) / 2;
    var _cy = instance_exists(obj_soul) ? obj_soul.y : (_in.y1 + _in.y2) / 2;

    var _min_x = _in.x1 + _r_max + ring_margin;
    var _max_x = _in.x2 - _r_max - ring_margin;
    var _min_y = _in.y1 + _r_max + ring_margin;
    var _max_y = _in.y2 - _r_max - ring_margin;
    if (_min_x > _max_x) { _min_x = (_min_x + _max_x) / 2; _max_x = _min_x; }
    if (_min_y > _max_y) { _min_y = (_min_y + _max_y) / 2; _max_y = _min_y; }
    _cx = clamp(_cx, _min_x, _max_x);
    _cy = clamp(_cy, _min_y, _max_y);

    var _offset = random(360);
    spawn_ring(_cx, _cy, _w.count, _w.radius, _w.aim, _w.stagger, _offset);
    if (_double)
    {
        spawn_ring(_cx, _cy, _w.count, _w.radius + double_gap, _w.aim + double_delay, _w.stagger, _offset + 180 / _w.count);
    }

    if (spawn_sound != -1) audio_play_sound(spawn_sound, 5, false);
};

all_fired = function()
{
    for (var i = 0; i < array_length(wave_spades); i++)
    {
        var _s = wave_spades[i];
        if (instance_exists(_s) && _s.aim_frames > 0) return false;
    }
    return true;
};