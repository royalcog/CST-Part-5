if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }

// box closing under it: everything fades out
if (obj_battlebox.state == "closing")
{
    fade_out -= 0.08;
    if (fade_out <= 0) instance_destroy();
    exit;
}

if (!started)
{
    if (scr_box_scale_settled()) timer--;
    if (timer > 0) exit;
    started = true;
}

t++;
var _in = scr_get_box_interior();
var _glow_at = attack_length - glow_frames;
var _glowing = (t >= _glow_at);

// --- spawn ---
if (spawned < star_count && t >= next_spawn && !_glowing)
{
    // a different side than the last one
    var _side = irandom(3);
    if (_side == last_side) _side = (_side + 1 + irandom(2)) mod 4;
    last_side = _side;

    var _x, _y;
    switch (_side)
    {
        case 0: _x = _in.x1 - spawn_dist; _y = random_range(_in.y1, _in.y2); break; // left
        case 1: _x = _in.x2 + spawn_dist; _y = random_range(_in.y1, _in.y2); break; // right
        case 2: _y = _in.y1 - spawn_dist; _x = random_range(_in.x1, _in.x2); break; // top
        case 3: _y = _in.y2 + spawn_dist; _x = random_range(_in.x1, _in.x2); break; // bottom
    }

    array_push(stars, { x: _x, y: _y, dir: point_direction(_x, _y, soul_x(), soul_y()),
                        spd: 0, alpha: 0, wait: appear_frames });
    spawned++;
    next_spawn = t + spawn_gap;
}

// --- stars hunting the soul ---
var _tx = soul_x();
var _ty = soul_y();
var _n  = array_length(stars);

for (var i = 0; i < _n; i++)
{
    var _s = stars[i];
    _s.alpha = min(_s.alpha + 1 / appear_frames, 1);

    var _want = point_direction(_s.x, _s.y, _tx, _ty);

    if (_s.wait > 0)
    {
        // just turns to keep facing the soul until it starts moving
        _s.wait--;
        _s.dir += angle_difference(_want, _s.dir) * 0.2;
        continue;
    }

    var _turn = _glowing ? turn_rate * 0.3 : turn_rate;
    _s.dir += clamp(angle_difference(_want, _s.dir), -_turn, _turn);
    _s.spd  = lerp(_s.spd, _glowing ? max_speed * glow_slow : max_speed, accel);

    _s.x += lengthdir_x(_s.spd, _s.dir);
    _s.y += lengthdir_y(_s.spd, _s.dir);
}

// nudge apart so they don't all stack into one star behind the soul
for (var i = 0; i < _n; i++)
{
    for (var j = i + 1; j < _n; j++)
    {
        var _a = stars[i], _b = stars[j];
        var _d = point_distance(_a.x, _a.y, _b.x, _b.y);
        if (_d < separation && _d > 0.01)
        {
            var _push = (separation - _d) * 0.05;
            var _dir  = point_direction(_b.x, _b.y, _a.x, _a.y);
            _a.x += lengthdir_x(_push, _dir); _a.y += lengthdir_y(_push, _dir);
            _b.x -= lengthdir_x(_push, _dir); _b.y -= lengthdir_y(_push, _dir);
        }
    }
}

// star hits
if (instance_exists(obj_soul) && !obj_soul.invulnerable)
{
    for (var i = 0; i < _n; i++)
    {
        var _s = stars[i];
        if (_s.alpha >= 1 && point_distance(_s.x, _s.y, obj_soul.x, obj_soul.y) <= star_hit_radius)
        {
            scr_soul_take_hit(star_damage, hit_color_top, hit_color_bottom);
            break;
        }
    }
}

// --- explode ---
if (!exploded && t >= attack_length)
{
    exploded = true;
    for (var i = 0; i < array_length(stars); i++)
    {
        var _s = stars[i];
        var _base = random(360);
        for (var k = 0; k < shard_count; k++)
        {
            var _d = _base + k * (360 / shard_count) + random_range(-10, 10);
            array_push(shards, { x: _s.x, y: _s.y, dir: _d, angle: _d,
                                 spd: shard_speed * random_range(0.8, 1.2), t: 0,
                                 spin: shard_spin * choose(-1, 1) });
        }
        array_push(flashes, { x: _s.x, y: _s.y, t: 0 });
    }
    stars = [];
    if (explode_sound != noone) audio_play_sound(explode_sound, 1, false);
    scr_camera_shake(explode_shake, 10);
}

// --- shards ---
for (var i = array_length(shards) - 1; i >= 0; i--)
{
    var _h = shards[i];
    _h.x += lengthdir_x(_h.spd, _h.dir);
    _h.y += lengthdir_y(_h.spd, _h.dir);
    _h.spd *= shard_friction;
    _h.angle += _h.spin * (_h.spd / shard_speed + 0.2);
    _h.t++;

    if (instance_exists(obj_soul) && !obj_soul.invulnerable
        && _h.t < shard_life - shard_fade / 2
        && point_distance(_h.x, _h.y, obj_soul.x, obj_soul.y) <= shard_hit_radius)
    {
        scr_soul_take_hit(shard_damage, hit_color_top, hit_color_bottom);
    }

    if (_h.t >= shard_life) array_delete(shards, i, 1);
}

// --- flashes ---
for (var i = array_length(flashes) - 1; i >= 0; i--)
{
    flashes[i].t++;
    if (flashes[i].t >= flash_frames) array_delete(flashes, i, 1);
}

if (exploded && array_length(shards) == 0 && array_length(flashes) == 0)
{
    instance_destroy();
}