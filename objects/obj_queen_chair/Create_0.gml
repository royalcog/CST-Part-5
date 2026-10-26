// Queen's floating chair. riders hop on and then stick to it (their feet locked to a spot on the chair),
// so whatever the chair does (float down, bob, fly off) they come along.
// x/y = the chair's origin (spr_queen_chair's seat)
sprite_index = spr_queen_chair;
image_xscale = 2;
image_yscale = 2;
image_speed  = 0;

// --- tuning ---
bob_amp      = 3;        // px it floats up and down
bob_speed    = 0.05;
bottom_dy    = 40;       // px from its origin down to the bottom of the chair (for the shadow tint)

summon_time  = 60;       // frames to float down into place (eases to a stop)
summon_sound = snd_appear;

dip_dist     = 10;       // liftoff: it sinks a little first...
dip_time     = 16;
lift_wait    = 6;        // ...holds a beat...
fly_time     = 70;       // ...then speeds up and away
fly_dist     = 700;      // px it travels up (well past the top of the screen)
fly_sound    = snd_wing;
sink_time    = 100;      // floating down instead (liftoff(..., 1)): frames to sink out of sight
sink_dist    = 420;      // px it sinks (past the bottom of the screen)

hop_sound    = snd_smallswing;

// the fireball out of its bottom, so you can tell it's flying (drawn behind the chair, lined up on the same canvas)
flame_sprite   = spr_queen_chair_flame;
flame_alpha    = 1;
flame_fly_grow = 0.6;    // it stretches this much longer while the chair's flying off

// --- state ---
state    = "idle";       // idle -> summon -> hover -> dip -> wait -> fly -> gone
t        = 0;
home_y   = y;            // where it hovers
from_y   = y;
base_y   = y;            // y before the bob
bob      = 0;
riders   = [];           // { inst, dx, dy, hopping, t, len, h, fx, fy, land_sprite, merge_sprite, done }
flame_frame  = 0;
flame_yscale = 1;
on_gone  = undefined;
fly_dir  = -1;           // -1 = flies up off the top, 1 = flies down off the bottom

/// floats down from where it is now to hover at _y
summon = function(_y)
{
    home_y = _y;
    from_y = y;
    base_y = y;
    state  = "summon";
    t = 0;
    if (summon_sound != noone) audio_play_sound(summon_sound, 1, false);
}

/// where a rider's feet go: (_dx, _dy) from the chair's origin
seat_point = function(_dx, _dy)
{
    return { x: x + _dx * sign(image_xscale), y: y + _dy };
}

/// _inst hops from where it's standing onto the chair. _land_sprite (or noone) once it's on.
/// _merge_sprite (or noone): instead of staying on as a rider, _inst disappears into the chair and the chair
/// becomes that sprite (Queen sitting in it). _on_done is called the moment it lands
add_rider = function(_inst, _dx, _dy, _frames, _height, _land_sprite = noone, _on_done = undefined, _merge_sprite = noone)
{
    if (!instance_exists(_inst)) { if (_on_done != undefined) _on_done(); return; }
    var _f = scr_get_feet(_inst);
    array_push(riders, {
        inst: _inst, dx: _dx, dy: _dy,
        hopping: true, t: 0, len: max(1, _frames), h: _height,
        fx: _f.x, fy: _f.y,
        land_sprite: _land_sprite, merge_sprite: _merge_sprite, done: _on_done
    });
    _inst.image_speed = 0;
    if (hop_sound != noone) audio_play_sound(hop_sound, 1, false, 0.7, 0, random_range(0.95, 1.1));
}

/// off it goes, riders and all. _on_done once it's gone (riders are destroyed with it).
/// _dir: -1 = flies up off the top of the screen, 1 = floats down off the bottom
liftoff = function(_on_done = undefined, _dir = -1)
{
    on_gone = _on_done;
    fly_dir = _dir;
    from_y  = base_y;
    state   = "dip";
    t = 0;
}

/// puts _inst's feet on (_x, _y)
set_feet = function(_inst, _x, _y)
{
    var _f = scr_get_feet(_inst);
    _inst.x += _x - _f.x;
    _inst.y += _y - _f.y;
}