if (sound_cooldown > 0) sound_cooldown--;

local_x += local_vx;
local_y += local_vy;

if (instance_exists(obj_battlebox))
{
    var _interior = scr_get_box_interior();
    var _min_x = _interior.x1 + margin;
    var _max_x = _interior.x2 - margin;
    var _min_y = _interior.y1 + margin;
    var _max_y = _interior.y2 - margin;

    var _bounced = false;

    if (local_x < _min_x)
    {
        local_x = _min_x;
        if (local_vx < 0) { local_vx = -local_vx; _bounced = true; }
    }
    else if (local_x > _max_x)
    {
        local_x = _max_x;
        if (local_vx > 0) { local_vx = -local_vx; _bounced = true; }
    }

    if (local_y < _min_y)
    {
        local_y = _min_y;
        if (local_vy < 0) { local_vy = -local_vy; _bounced = true; }
    }
    else if (local_y > _max_y)
    {
        local_y = _max_y;
        if (local_vy > 0) { local_vy = -local_vy; _bounced = true; }
    }

    if (_bounced)
    {
        var _dir = point_direction(0, 0, local_vx, local_vy);
        var _new_speed = random_range(min_speed, max_speed);
        local_vx = lengthdir_x(_new_speed, _dir);
        local_vy = lengthdir_y(_new_speed, _dir);
    }

    var _world = scr_box_local_to_world(local_x, local_y);
    x = _world.x;
    y = _world.y;

    if (_bounced && sound_cooldown <= 0)
    {
        audio_play_sound(snd_impact, 2, false);
        sound_cooldown = 6;
    }
}

image_angle -= local_vx * spin_factor;

// checked directly by distance instead of scr_attack_touches_soul() /
// position_meeting — that relies on the yarn's collision MASK, which
// doesn't rotate along with image_angle (GameMaker only rotates the
// visual, not the mask, unless you handle it yourself), so with the yarn
// spinning constantly for the tumble effect, hits were landing unreliably
if (instance_exists(obj_soul))
{
    var _hit_radius = margin * 0.7; // a bit tighter than the wall-collision margin — more like the visible ball
    var _soul_radius = 8;
    var _dist = point_distance(x, y, obj_soul.x, obj_soul.y);

    // TEMP DEBUG — remove once damage is confirmed working. Reports even
    // when it's close but not quite touching, so we can see in the
    // console whether this check is being reached at all, how close it's
    // actually getting, and whether invulnerable is unexpectedly stuck on
    if (_dist <= _hit_radius + _soul_radius + 60)
    {
        show_debug_message("yarn dist=" + string(_dist) + " threshold=" + string(_hit_radius + _soul_radius) + " invuln=" + string(obj_soul.invulnerable));
    }

    if (_dist <= _hit_radius + _soul_radius)
    {
        scr_soul_take_hit(0, obj_mewmew.damage_color, obj_mewmew.damage_color);
    }
}