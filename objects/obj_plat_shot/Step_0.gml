t++;
var _spd  = (kind == "buster") ? buster_speed : fire_speed;
var _turn = (kind == "buster") ? buster_turn  : fire_turn;

// home in on its target (if it's still around), the short way around the tower
if (instance_exists(target) && !target.dying)
{
    var _want = point_direction(0, 0, scr_plat_wrap_dx(x, target.x), target.y - y);
    dir += clamp(angle_difference(_want, dir), -_turn, _turn);
}

if (kind == "buster")
{
    array_insert(trail, 0, { x: x, y: y, a: dir });
    if (array_length(trail) > trail_len) array_pop(trail);
}

x += lengthdir_x(_spd, dir);
y += lengthdir_y(_spd, dir);
x  = scr_plat_wrap(x);
image_angle = dir;

// hit any Titan Spawn it reaches
var _hit = noone;
with (obj_plat_titanspawn)
{
    if (!dying && point_distance(0, 0, scr_plat_wrap_dx(other.x, x), y - other.y) <= other.hit_r) { _hit = id; break; }
}
if (_hit != noone)
{
    _hit.take_damage(x, y);
    if (kind == "fire") audio_play_sound(snd_firespell, 1, false);
    var _fx = instance_create_depth(_hit.x, _hit.y, depth, obj_plat_fx);
    _fx.setup((kind == "buster") ? "buster" : "swarm", _hit);
    instance_destroy();
    exit;
}

if (t >= life) instance_destroy();