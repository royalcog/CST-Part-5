if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
if (obj_battlebox.state == "closing") fading = true;
if (fading)
{
    image_alpha -= 0.1;
    if (image_alpha <= 0) instance_destroy();
    exit;
}

t++;
// appearing, like every darkshape: fades in, then aims at the SOUL
if (image_alpha < 1)
{
    image_alpha = min(1, image_alpha + 0.0125);
    if (image_alpha < 1) exit;
    if (instance_exists(obj_soul)) dir = point_direction(x, y, obj_soul.x, obj_soul.y);
}
if (!instance_exists(obj_soul)) exit;
var _sx = obj_soul.x, _sy = obj_soul.y;

if (point_distance(x, y, _sx, _sy) < arm_range || fuse > 0)
{
    // armed: it slows to a stop and its fuse runs
    if (fuse == 0) audio_play_sound(snd_swallow, 1, false, 1, 0, 0.65);
    spd  = scr_approach(spd, 0, spd * 0.025);
    fuse = min(1, fuse + fuse_rate);
    if (fuse >= 1)
    {
        // boom: a red shockwave and 5 bullets fanned out at the SOUL
        audio_play_sound(snd_chargeshot_fire, 1, false);
        instance_create_depth(x, y, depth - 1, obj_mine_blast);
        var _aim = point_direction(x, y, _sx, _sy);
        for (var i = 0; i < 5; i++)
            with (instance_create_depth(x, y, depth, obj_mine_bullet))
            {
                damage = other.damage;
                dir    = _aim - 60 + 30 * i + random_range(-5, 5);
                spd0   = (1.5 + random(1.5)) / 2;   // DR 1.5-3, then x4 over 30 of its frames
            }
        instance_destroy();
        exit;
    }
}
else spd = scr_approach(spd, speed_max, accel);

// turns toward the SOUL (its own turning + the stroke-turning every darkshape has)
var _turn = tracking + 16 * (0.5 - sin(t * 0.075) * 0.5) / 2;
dir += clamp(angle_difference(point_direction(x, y, _sx, _sy), dir), -_turn, _turn);
x += lengthdir_x(spd, dir);
y += lengthdir_y(spd, dir);

// it shoves copies out of its way
with (obj_darkshape)
    if (point_distance(x, y, other.x, other.y) < 22 * other.art_scale)
    {
        var _a = point_direction(other.x, other.y, x, y);
        x += lengthdir_x(0.5, _a);
        y += lengthdir_y(0.5, _a);
    }

// touching it hurts
if (!obj_soul.invulnerable && point_distance(x, y, _sx, _sy) <= hit_r)
    scr_soul_take_hit(damage, c_white, c_white);