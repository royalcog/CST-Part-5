if (!instance_exists(obj_battlebox)) { instance_destroy(); exit; }
if (obj_battlebox.state == "closing") fading_out = true;

x += lengthdir_x(move_speed, move_dir);
y += lengthdir_y(move_speed, move_dir);

if (fading_out)
{
    image_alpha -= 1 / fade_frames;
    if (image_alpha <= 0) { instance_destroy(); exit; }
}

if (!fading_out && instance_exists(obj_soul) && !obj_soul.invulnerable
 && point_distance(x, y, obj_soul.x, obj_soul.y) <= hit_radius)
{
    scr_soul_take_hit(damage, c_white, c_white);
    instance_destroy();
    exit;
}

// gone once it's fully left the box
var _in = scr_get_box_interior();
var _r = 20;
if (x < _in.x1 - _r || x > _in.x2 + _r || y < _in.y1 - _r || y > _in.y2 + _r)
{
    instance_destroy();
}